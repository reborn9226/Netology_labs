#!/bin/bash

# Версия PostgreSQL
PG_VERSION="17"

# Путь для сохранения резервных копий
BACKUP_PATH="/var/lib/pgsql/17/backups/"

# Список баз данных для резервного копирования и обслуживания
DATABASES=("unf_linux")

# Формат резервной копии (custom/directory/plain)
BACKUP_FORMAT="directory"

# Уровень сжатия PostgreSQL (1-9)
COMPRESS_LEVEL=6

# Количество потоков для резервного копирования pg_dump
BACKUP_THREADS=10

# Количество потоков для параллельного REINDEX и VACUUM ANALYZE
MAINTENANCE_THREADS=10

# Удалять старые локальные резервные копии
REMOVE_OLD_BACKUPS=true

# Хранить резервные копии указанное количество дней (локально)
RETENTION_DAYS=7

# Минимальное свободное место в GB
MIN_FREE_SPACE=25


# НАСТРОЙКИ SMB Сетевая папка Windows на старом сервере хранилища.

SMB_ENABLED=true
SMB_HOST="10.10.10.1"
SMB_SHARE="backup_1c_linux"              # Имя расшаренной папки в Windows
SMB_USER="пользователь"          # Имя пользователя Windows тут указаны данные для примера
SMB_PASSWORD="пароль"  # Пароль пользователя Windows тут указаны данные для примера
SMB_DOMAIN=""
SMB_MOUNT_POINT="/mnt/win_backups"

SMB_REMOVE_OLD=true
SMB_RETENTION_DAYS=7             # Сколько дней хранить на Windows-машине


# НАСТРОЙКИ POSTGRESQL И ЛОГОВ


PG_BIN_PATH="/usr/pgsql-${PG_VERSION}/bin"
PG_PSQL="${PG_BIN_PATH}/psql"
PG_DUMP="${PG_BIN_PATH}/pg_dump"
PG_DUMPALL="${PG_BIN_PATH}/pg_dumpall"
PG_LOG="/home/int/backup_log"     # Путь для логов резервного копирования и обслуживания

# Формат даты: ДД.ММ.ГГГГ_ЧЧ-ММ
TIMESTAMP=$(date +%d.%m.%Y_%H-%M)
LOG_FILE="${PG_LOG}/backup_${TIMESTAMP}.log"
MAINTENANCE_LOG_FILE="${PG_LOG}/maintenance_${TIMESTAMP}.log"

# Коды возврата
EXIT_SUCCESS=0
EXIT_ERROR_LOCK=1
EXIT_ERROR_DISK_SPACE=2
EXIT_ERROR_DATABASE=3
EXIT_ERROR_BACKUP=4
EXIT_ERROR_SMB=6
EXIT_ERROR_CLEANUP=7

# Флаги состояния
BACKUP_FAILED=0
SMB_FAILED=0
MAINTENANCE_FAILED=0


# БАЗОВЫЕ ФУНКЦИИ И ПРОВЕРКИ

# Создаем блокировку перед резервным копированием
acquire_lock() {
    LOCK_FILE="/var/lock/pg_backup.lock"
    local lock_dir=$(dirname "$LOCK_FILE")
    mkdir -p "$lock_dir" 2>/dev/null

    local wait_time=0
    while [ $wait_time -lt 300 ]; do
        if mkdir "$LOCK_FILE" 2>/dev/null; then
            echo $$ > "$LOCK_FILE/pid"
            echo "Блокировка успешно получена (PID: $$)" | tee -a "$LOG_FILE"
            return 0
        fi

        if [ -f "$LOCK_FILE/pid" ]; then
            local old_pid=$(cat "$LOCK_FILE/pid" 2>/dev/null)
            if [ -n "$old_pid" ] && ! kill -0 "$old_pid" 2>/dev/null; then
                echo "Обнаружена устаревшая блокировка (PID: $old_pid), удаляем..." | tee -a "$LOG_FILE"
                rm -rf "$LOCK_FILE"
                continue
            fi
        fi

        echo "Ожидание освобождения блокировки... ($wait_time/300 сек)" | tee -a "$LOG_FILE"
        sleep 10
        wait_time=$((wait_time + 10))
    done

    echo "ОШИБКА: Не удалось получить блокировку в течение 300 секунд" | tee -a "$LOG_FILE"
    return 1
}

# Освобождаем блокировку
release_lock() {
    LOCK_FILE="/var/lock/pg_backup.lock"
    if [ -d "$LOCK_FILE" ]; then
        rm -rf "$LOCK_FILE"
        echo "Блокировка освобождена" | tee -a "$LOG_FILE"
    fi
}

# проверяем наличие всех команд
check_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then missing+=("$cmd"); fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "ОШИБКА: Не найдены команды: ${missing[*]}" | tee -a "$LOG_FILE"
        return 1
    fi
    return 0
}

# Проверяем наличие баз
check_databases() {
    local missing=()
    for db in "${DATABASES[@]}"; do
        if ! sudo -u postgres "$PG_PSQL" -lqt | cut -d \| -f 1 | grep -qw "$db"; then
            missing+=("$db")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "ОШИБКА: Не найдены БД: ${missing[*]}" | tee -a "$LOG_FILE"
        return 1
    fi
    return 0
}

# Высчитываем свободное пространство для бэкапа на локальном диске
check_disk_space() {
    local required=$1
    local available=$(df -k --output=avail "$BACKUP_PATH" | tail -1)
    local available_gb=$((available / 1024 / 1024))

    if [ "$available" -lt "$((required * 1024 * 1024))" ]; then
        echo "ОШИБКА: Недостаточно места в ${BACKUP_PATH}!" | tee -a "$LOG_FILE"
        echo "Доступно: ${available_gb}GB, Требуется: ${required}GB" | tee -a "$LOG_FILE"
        return 1
    fi
    echo "Проверка дискового пространства: ${available_gb}GB доступно" | tee -a "$LOG_FILE"
    return 0
}


# ФУНКЦИИ РЕЗЕРВНОГО КОПИРОВАНИЯ

# Делам сжатую копию глобальных данных всего кластера
backup_globals() {
    echo "Сохранение глобальных объектов..." | tee -a "$LOG_FILE"
    local globals_file="${BACKUP_PATH}/globals_${TIMESTAMP}.sql.gz"
    if sudo -u postgres "$PG_DUMPALL" --globals-only 2>> "$LOG_FILE" | gzip > "$globals_file"; then
        echo "Успешно: глобальные объекты сохранены" | tee -a "$LOG_FILE"
        return 0
    else
        echo "ОШИБКА: Не удалось сохранить глобальные объекты" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Резервное копирование базы данных разными форматами, вверху переменная с выбором формата.
backup_databases() {
    local failed=()
    for db in "${DATABASES[@]}"; do
        echo "----------------------------------------" | tee -a "$LOG_FILE"
        echo "Резервное копирование: $db" | tee -a "$LOG_FILE"
        echo "Время начала: $(date +'%H:%M:%S')" | tee -a "$LOG_FILE"

        local backup_name="${db}_${TIMESTAMP}"
        local result=0

        case $BACKUP_FORMAT in
            "custom")
                local dump_file="${BACKUP_PATH}/${backup_name}.dump"
                sudo -u postgres "$PG_DUMP" -Fc -Z "$COMPRESS_LEVEL" -j "$BACKUP_THREADS" -f "$dump_file" "$db" >> "$LOG_FILE" 2>&1
                result=$?
                ;;
            "directory")
                local dump_dir="${BACKUP_PATH}/${backup_name}"
                mkdir -p "$dump_dir" && chown postgres:postgres "$dump_dir"
                sudo -u postgres "$PG_DUMP" -Fd -Z "$COMPRESS_LEVEL" -j "$BACKUP_THREADS" -f "$dump_dir" "$db" >> "$LOG_FILE" 2>&1
                result=$?
                ;;
            "plain")
                local dump_file="${BACKUP_PATH}/${backup_name}.sql.gz"
                sudo -u postgres "$PG_DUMP" -Fp "$db" 2>> "$LOG_FILE" | gzip -${COMPRESS_LEVEL} > "$dump_file"
                result=$?
                ;;
        esac

        if [ $result -eq 0 ]; then
            echo "Успешно: $db → ${backup_name}" | tee -a "$LOG_FILE"
            echo "Время окончания: $(date +'%H:%M:%S')" | tee -a "$LOG_FILE"
        else
            echo "ОШИБКА: Не удалось создать копию $db" | tee -a "$LOG_FILE"
            failed+=("$db")
            BACKUP_FAILED=1
        fi
    done

    if [ ${#failed[@]} -gt 0 ]; then
        echo "ВНИМАНИЕ: Резервное копирование не выполнено для: ${failed[*]}" | tee -a "$LOG_FILE"
        return 1
    fi
    return 0
}


# ФУНКЦИИ SMB

#Монтирование сетевой папки перед backup
mount_smb() {
    if [ "$SMB_ENABLED" = false ]; then return 0; fi
    mkdir -p "$SMB_MOUNT_POINT"

    if mountpoint -q "$SMB_MOUNT_POINT"; then
        return 0
    fi

    local mount_opts="username=${SMB_USER},password=${SMB_PASSWORD},dir_mode=0777,file_mode=0777"
    if [ -n "$SMB_DOMAIN" ]; then mount_opts="${mount_opts},domain=${SMB_DOMAIN}"; fi

    echo "Монтирование шары //${SMB_HOST}/${SMB_SHARE}..." | tee -a "$LOG_FILE"
    if mount -t cifs "//${SMB_HOST}/${SMB_SHARE}" "$SMB_MOUNT_POINT" -o "$mount_opts" >> "$LOG_FILE" 2>&1; then
        echo "✓ SMB шара успешно примонтирована" | tee -a "$LOG_FILE"
        return 0
    else
        echo "ОШИБКА: Не удалось примонтировать SMB шару (проверьте пакет cifs-utils)" | tee -a "$LOG_FILE"
        SMB_FAILED=1
        return 1
    fi
}

#  После выполнение backup отмонтируем
unmount_smb() {
    if mountpoint -q "$SMB_MOUNT_POINT"; then
        echo "Отмонтирование SMB шары..." | tee -a "$LOG_FILE"
        umount "$SMB_MOUNT_POINT" || umount -l "$SMB_MOUNT_POINT"
    fi
}

# Копирование готовых копий в сетевую папку
replicate_to_smb() {
    if [ "$SMB_ENABLED" = false ] || [ "$SMB_FAILED" -eq 1 ]; then return 0; fi

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Копирование в сетевую папку Windows" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"

    local upload_failed=0

    # Копируем глобальные объекты
    local globals_file="${BACKUP_PATH}/globals_${TIMESTAMP}.sql.gz"
    if [ -f "$globals_file" ]; then
        cp "$globals_file" "$SMB_MOUNT_POINT/" || upload_failed=1
    fi

    # Копируем базы
    for db in "${DATABASES[@]}"; do
        local backup_name="${db}_${TIMESTAMP}"

        if [ "$BACKUP_FORMAT" = "directory" ]; then
            local dump_dir="${BACKUP_PATH}/${backup_name}"
            if [ -d "$dump_dir" ]; then
                echo "Копирование директории $backup_name..." | tee -a "$LOG_FILE"
                cp -r "$dump_dir" "$SMB_MOUNT_POINT/" || upload_failed=1
            fi
        else
            local dump_file="${BACKUP_PATH}/${backup_name}.dump"
            [ ! -f "$dump_file" ] && dump_file="${BACKUP_PATH}/${backup_name}.sql.gz"

            if [ -f "$dump_file" ]; then
                echo "Копирование файла $(basename "$dump_file")..." | tee -a "$LOG_FILE"
                cp "$dump_file" "$SMB_MOUNT_POINT/" || upload_failed=1
            fi
        fi
    done

    if [ $upload_failed -eq 0 ]; then
        echo "Репликация по SMB завершена успешно" | tee -a "$LOG_FILE"
    else
        echo "ВНИМАНИЕ: Ошибка при копировании файлов по SMB" | tee -a "$LOG_FILE"
        SMB_FAILED=1
        return 1
    fi
}


# ФУНКЦИИ ОБСЛУЖИВАНИЯ

# Выполнение REINDEX и VACUUM ANALYZE паралельно используя несколько ядер процессора
run_maintenance() {
    echo "========================================" | tee -a "$LOG_FILE"
    echo "Начало параллельного обслуживания баз данных (детали в ${MAINTENANCE_LOG_FILE})" | tee -a "$LOG_FILE"
    echo "Потоков для обслуживания: $MAINTENANCE_THREADS" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"

    echo "========================================" > "$MAINTENANCE_LOG_FILE"
    echo "Начало параллельного обслуживания: $(date +'%d.%m.%Y %H:%M:%S')" >> "$MAINTENANCE_LOG_FILE"
    echo "Потоков: $MAINTENANCE_THREADS" >> "$MAINTENANCE_LOG_FILE"
    echo "========================================" >> "$MAINTENANCE_LOG_FILE"

    local overall_failed=0

    for db in "${DATABASES[@]}"; do
        echo "--> Обслуживание базы данных: $db..." | tee -a "$LOG_FILE"
        echo "--> Обслуживание базы данных: $db" >> "$MAINTENANCE_LOG_FILE"

        local TABLES=$(sudo -u postgres "$PG_PSQL" -d "$db" -t -c "SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relkind = 'r' AND c.relname NOT LIKE 'pg_%' AND c.relname NOT LIKE 'sql_%'")

        local job_counter=0
        local max_jobs=$MAINTENANCE_THREADS
        local overall_failed_db=0
        local db_failed=0

        for TABLE in $TABLES; do
            (
                local CURRENT_PID=$$
                echo "    -> [PID $CURRENT_PID] $db: Обслуживание таблицы $TABLE (Начало)" >> "$MAINTENANCE_LOG_FILE"

                if ! sudo -u postgres "$PG_PSQL" -d "$db" -c "REINDEX TABLE \"$TABLE\"" >> "$MAINTENANCE_LOG_FILE" 2>&1; then
                    echo "    ✗ ОШИБКА REINDEX TABLE [PID $CURRENT_PID] для $db.$TABLE" >> "$MAINTENANCE_LOG_FILE"
                    exit 1
                fi

                if ! sudo -u postgres "$PG_PSQL" -d "$db" -c "VACUUM ANALYZE \"$TABLE\"" >> "$MAINTENANCE_LOG_FILE" 2>&1; then
                    echo "    ✗ ОШИБКА VACUUM ANALYZE [PID $CURRENT_PID] для $db.$TABLE" >> "$MAINTENANCE_LOG_FILE"
                    exit 1
                fi

                echo "    ✓ [PID $CURRENT_PID] $db: Обслуживание таблицы $TABLE завершено." >> "$MAINTENANCE_LOG_FILE"
            ) &

            job_counter=$((job_counter + 1))

            if [ $job_counter -ge $max_jobs ]; then
                wait -n
                if [ $? -ne 0 ]; then
                    overall_failed_db=1
                fi
                job_counter=$((job_counter - 1))
            fi
        done

        while [ $job_counter -gt 0 ]; do
            wait -n
            if [ $? -ne 0 ]; then
                overall_failed_db=1
            fi
            job_counter=$((job_counter - 1))
        done

        if [ "$overall_failed_db" -ne 0 ]; then
            db_failed=1
            overall_failed=1
        fi

        if [ "$db_failed" -eq 0 ]; then
            echo "--> Обслуживание $db завершено успешно." | tee -a "$LOG_FILE"
        else
            echo "--> ВНИМАНИЕ: Обслуживание $db завершено с ошибками. См. ${MAINTENANCE_LOG_FILE}" | tee -a "$LOG_FILE"
        fi
        echo "" >> "$MAINTENANCE_LOG_FILE"
    done

    if [ "$overall_failed" -ne 0 ]; then
        MAINTENANCE_FAILED=1
        echo "Параллельное обслуживание завершено с ошибками." | tee -a "$LOG_FILE"
        return 1
    fi

    echo "Параллельное обслуживание всех баз данных завершено успешно." | tee -a "$LOG_FILE"
    return 0
}


# ФУНКЦИИ ОЧИСТКИ

# Удаление устаревших резервных копий и логов на локальном сервере
remove_old_backups_local() {
    if [ "$REMOVE_OLD_BACKUPS" = false ]; then return 0; fi
    echo "========================================" | tee -a "$LOG_FILE"
    echo "Удаление локальных копий старше $RETENTION_DAYS дней" | tee -a "$LOG_FILE"

    local deleted=0
    local RETENTION_MIN=$((RETENTION_DAYS * 1440))

    while IFS= read -r -d '' file; do
        echo "Удаление: $(basename "$file")" | tee -a "$LOG_FILE"
        rm -f "$file"
        deleted=$((deleted+1))
    done < <(find "$BACKUP_PATH" -type f \( -name "*.dump" -o -name "*.sql.gz" -o -name "*.tar.gz" -o -name "*.tar" \) -mmin +$RETENTION_MIN -print0)

    while IFS= read -r -d '' dir; do
        echo "Удаление директории: $(basename "$dir")" | tee -a "$LOG_FILE"
        rm -rf "$dir"
        deleted=$((deleted+1))
    done < <(find "$BACKUP_PATH" -type d -name "*_*.*.*_*-*" -mmin +$RETENTION_MIN -print0)

    if [ -d "$PG_LOG" ]; then
        while IFS= read -r -d '' log; do
            rm -f "$log"
        done < <(find "$PG_LOG" -type f \( -name "backup_*.log" -o -name "maintenance_*.log" \) -mmin +$RETENTION_MIN -print0)
    fi

    find "$BACKUP_PATH" -type d -empty -delete 2>/dev/null
    echo "Удалено локальных объектов: $deleted" | tee -a "$LOG_FILE"
}

# Удаление устаревших резервных копий на сетевой папке
remove_old_backups_smb() {
    if [ "$SMB_ENABLED" = false ] || [ "$SMB_REMOVE_OLD" = false ] || ! mountpoint -q "$SMB_MOUNT_POINT"; then return 0; fi

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Удаление копий на SMB старше $SMB_RETENTION_DAYS дней" | tee -a "$LOG_FILE"

    local deleted=0
    local RETENTION_MIN=$((SMB_RETENTION_DAYS * 1440))

    while IFS= read -r -d '' file; do
        echo "Удаление на SMB: $(basename "$file")" | tee -a "$LOG_FILE"
        rm -f "$file"
        deleted=$((deleted+1))
    done < <(find "$SMB_MOUNT_POINT" -type f \( -name "*.dump" -o -name "*.sql.gz" -o -name "*.tar.gz" -o -name "*.tar" \) -mmin +$RETENTION_MIN -print0)

    while IFS= read -r -d '' dir; do
        echo "Удаление директории на SMB: $(basename "$dir")" | tee -a "$LOG_FILE"
        rm -rf "$dir"
        deleted=$((deleted+1))
    done < <(find "$SMB_MOUNT_POINT" -type d -name "*_*.*.*_*-*" -mmin +$RETENTION_MIN -print0)

    find "$SMB_MOUNT_POINT" -type d -empty -delete 2>/dev/null
    echo "Удалено объектов на SMB: $deleted" | tee -a "$LOG_FILE"
}


# ЗАВЕРШЕНИЕ


cleanup() {
    local exit_code=$?
    unmount_smb
    release_lock
    echo "========================================" | tee -a "$LOG_FILE"
    echo "Скрипт завершен с кодом: $exit_code" | tee -a "$LOG_FILE"
    echo "Время завершения: $(date +'%d.%m.%Y %H:%M:%S')" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
}

trap_handler() {
    echo "" | tee -a "$LOG_FILE"
    echo "Получен сигнал прерывания!" | tee -a "$LOG_FILE"
    cleanup
    exit 130
}

trap cleanup EXIT
trap trap_handler INT TERM


# Представление скрипта


mkdir -p "$BACKUP_PATH"
mkdir -p "$PG_LOG"

echo "========================================" > "$LOG_FILE"
echo "PostgreSQL Backup Script "   | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "Начало: $(date +'%d.%m.%Y %H:%M:%S')" | tee -a "$LOG_FILE"
echo "Хост: $(hostname)" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

if ! acquire_lock; then
    exit $EXIT_ERROR_LOCK
fi

if ! check_commands sudo "${PG_PSQL}" "${PG_DUMP}" "${PG_DUMPALL}" find rm cp mount; then
    exit $EXIT_ERROR_DATABASE
fi

if ! check_databases; then
    exit $EXIT_ERROR_DATABASE
fi

if ! check_disk_space $MIN_FREE_SPACE; then
    exit $EXIT_ERROR_DISK_SPACE
fi

remove_old_backups_local

echo "========================================" | tee -a "$LOG_FILE"
echo "Конфигурация резервного копирования и обслуживания" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "Версия PostgreSQL: ${PG_VERSION}" | tee -a "$LOG_FILE"
echo "Путь сохранения: ${BACKUP_PATH}" | tee -a "$LOG_FILE"
echo "Базы данных: ${DATABASES[*]}" | tee -a "$LOG_FILE"
echo "Формат: ${BACKUP_FORMAT}" | tee -a "$LOG_FILE"
echo "Потоки (Бэкап/Обслуживание): ${BACKUP_THREADS}/${MAINTENANCE_THREADS}" | tee -a "$LOG_FILE"
echo "Срок хранения локальных/SMB копий: ${RETENTION_DAYS}/${SMB_RETENTION_DAYS} дней" | tee -a "$LOG_FILE"
echo "SMB-шара: //${SMB_HOST}/${SMB_SHARE}" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

echo "========================================" | tee -a "$LOG_FILE"
echo "Начало резервного копирования" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

if ! backup_globals; then
    BACKUP_FAILED=1
fi

if ! backup_databases; then
    BACKUP_FAILED=1
fi

if [ $BACKUP_FAILED -eq 0 ]; then
    if ! run_maintenance; then
        MAINTENANCE_FAILED=1
    fi
else
    echo "Пропуск обслуживания баз данных из-за ошибок резервного копирования" | tee -a "$LOG_FILE"
fi

if [ $BACKUP_FAILED -eq 0 ]; then
    if mount_smb; then
        if ! replicate_to_smb; then
            SMB_FAILED=1
        fi
        remove_old_backups_smb
    else
        SMB_FAILED=1
    fi
else
    echo "Пропуск репликации на SMB из-за ошибок в резервном копировании" | tee -a "$LOG_FILE"
fi

echo "========================================" | tee -a "$LOG_FILE"
echo "Статистика резервного копирования" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "Размер резервных копий:" | tee -a "$LOG_FILE"
du -sh "${BACKUP_PATH}"/* 2>/dev/null | tail -20 | tee -a "$LOG_FILE"
echo "Основной лог сохранен: ${LOG_FILE}" | tee -a "$LOG_FILE"
echo "Лог обслуживания сохранен: ${MAINTENANCE_LOG_FILE}" | tee -a "$LOG_FILE"

if [ $BACKUP_FAILED -ne 0 ]; then
    echo "ЗАВЕРШЕНО С ОШИБКАМИ: Резервное копирование не выполнено" | tee -a "$LOG_FILE"
    exit $EXIT_ERROR_BACKUP
elif [ $MAINTENANCE_FAILED -ne 0 ]; then
    echo "ЗАВЕРШЕНО С ПРЕДУПРЕЖДЕНИЯМИ: Обслуживание завершено с ошибками" | tee -a "$LOG_FILE"
    exit $EXIT_ERROR_CLEANUP
elif [ $SMB_FAILED -ne 0 ]; then
    echo "ЗАВЕРШЕНО С ПРЕДУПРЕЖДЕНИЯМИ: SMB репликация не выполнена" | tee -a "$LOG_FILE"
    exit $EXIT_ERROR_SMB
else
    echo "УСПЕШНО ЗАВЕРШЕНО" | tee -a "$LOG_FILE"
    exit $EXIT_SUCCESS
fi