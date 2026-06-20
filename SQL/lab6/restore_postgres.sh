#!/bin/bash
# Версия PostgreSQL
PG_VERSION="17"
# Путь для сканирования локальных резервных копий
BACKUP_PATH="/var/lib/pgsql/17/backups"

# Максимальное количество отображаемых копий для выбора
MAX_COPIES_TO_SHOW=10

# Файлы логов
TIMESTAMP=$(date +%d.%m.%Y_%H-%M)
LOG_FILE="${BACKUP_PATH}/restore_${TIMESTAMP}.log"


# НАСТРОЙКИ POSTGRESQL


PG_BIN_PATH="/usr/pgsql-${PG_VERSION}/bin"
PG_PSQL="${PG_BIN_PATH}/psql"
PG_RESTORE="${PG_BIN_PATH}/pg_restore"
PG_DROPDB="${PG_BIN_PATH}/dropdb"
PG_CREATEDB="${PG_BIN_PATH}/createdb"

# Глобальные переменные для отслеживания временных файлов (для tar-архивов)
TEMP_FILES_TO_CLEANUP=()


# УТИЛИТЫ И ЛОГИРОВАНИЕ


log() {
    # Общая функция лога, которая пишет и в STDOUT, и в LOG_FILE
    echo "$(date +'%H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Функция для записи только в лог-файл
log_only() {
    echo "$(date +'%H:%M:%S') $1" >> "$LOG_FILE"
}

check_commands() {
    local required_cmds=(sudo "$PG_PSQL" "$PG_RESTORE" "$PG_DROPDB" "$PG_CREATEDB" find sort gzip tar sed)
    local missing_commands=()
    for cmd in "${required_cmds[@]}"; do
        # Проверяем исполняемый файл или команду
        if ! command -v "$cmd" &> /dev/null && [ ! -x "$cmd" ]; then
            missing_commands+=("$(basename "$cmd")")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log "ОШИБКА: Не найдены команды: ${missing_commands[*]}"
        return 1
    fi
    return 0
}

cleanup() {
    local exit_code=$?

    # Удаление временных файлов
    if [ ${#TEMP_FILES_TO_CLEANUP[@]} -gt 0 ]; then
        log "Удаление временных файлов: ${TEMP_FILES_TO_CLEANUP[*]}"
        rm -rf "${TEMP_FILES_TO_CLEANUP[@]}" 2>> "$LOG_FILE"
    fi

    log "========================================"
    log "Скрипт завершен с кодом: $exit_code"
    log "Время завершения: $(date +'%d.%m.%Y %H:%M:%S')"
    log "========================================"
}

trap cleanup EXIT


# ФУНКЦИИ СКАНИРОВАНИЯ


# Сканирование локальной папки
scan_local_backups() {
    local BACKUP_PATH="$1"

    log "Сканирование локальной папки: $BACKUP_PATH"

    local i=1
    local -A backup_details


    # Ищем файлы: *.dump, *.sql.gz, *.tar или директории по маске *_*.*.*_*-*
    while IFS= read -r item; do

        local basename=$(basename "$item")

        # 1. Извлечение времени (XX.XX.XXXX_XX-XX)
        local timestamp=$(echo "$basename" | sed -E 's/.*([0-9]{2}\.[0-9]{2}\.[0-9]{4}_[0-9]{2}-[0-9]{2}).*$/\1/')

        # 2. Извлечение имени БД
        local db_name=$(echo "$basename" | sed -E 's/([a-zA-Z0-9_-]+)_[0-9]{2}\.[0-9]{2}\.[0-9]{4}_[0-9]{2}-[0-9]{2}.*$/\1/')

        local format=""

        if [[ "$item" =~ \.dump$ ]]; then
            format="custom"
        elif [[ "$item" =~ \.sql\.gz$ ]]; then
            format="plain"
        elif [ -d "$item" ]; then
            format="directory"
        elif [[ "$item" =~ \.tar$ ]]; then
            format="directory (tar)"
        else
            continue # Пропускаем невалидные файлы
        fi

        if [ -z "$db_name" ] || [ -z "$timestamp" ]; then
            log_only "ВНИМАНИЕ: Пропущен локальный файл. Не удалось извлечь DB/Время из имени: $basename"
            continue
        fi

        backup_details["$i,path"]="$item"
        backup_details["$i,db"]="$db_name"
        backup_details["$i,format"]="$format"
        backup_details["$i,time"]="$timestamp"
        i=$((i + 1))
    done < <(find "$BACKUP_PATH" -maxdepth 1 -type f \( -name "*.dump" -o -name "*.sql.gz" -o -name "*.tar" \) -o -type d -name "*_*.*.*_*-*")

    # Возвращаем детали как строку для обработки вне цикла
    for key in "${!backup_details[@]}"; do
        echo "$key ${backup_details[$key]}"
    done
}



# ФУНКЦИИ ВЫБОРА ПАРАМЕТРОВ


# Выбор целевой базы данных
select_target_db() {
    local original_db="$1"
    local target_db=""
    local choice=0

    while true; do
        # Вывод меню на /dev/tty для обхода буферизации
        printf "\nВыберите режим восстановления:\n" > /dev/tty
        printf "1) Восстановить в ту же базу данных: %s (требуется удаление/пересоздание)\n" "$original_db" > /dev/tty
        printf "2) Создать новую базу данных (стандарта 1С) и восстановить в нее\n" > /dev/tty

        printf "Ваш выбор (1 или 2): " > /dev/tty
        read -r choice < /dev/tty # Чтение ввода напрямую с терминала

        # Запись в лог-файл
        log_only "Пользователь выбрал режим восстановления: $choice"

        if [ "$choice" == "1" ]; then
            target_db="$original_db"
            local action="replace"
            break
        elif [ "$choice" == "2" ]; then
            while true; do
                printf "Введите имя новой базы данных (например, 'new_db_1c'): " > /dev/tty
                read -r target_db < /dev/tty
                if [[ "$target_db" =~ ^[a-zA-Z0-9_]+$ ]] && [ -n "$target_db" ]; then
                    break
                else
                    log "ОШИБКА: Имя базы данных содержит недопустимые символы. Используйте только латинские буквы, цифры и '_'."
                fi
            done
            local action="new"
            break
        else
            log "Неверный выбор. Пожалуйста, введите 1 или 2."
        fi
    done

    # Только финальное значение попадает в STDOUT для захвата
    echo "$target_db,$action"
}

# Выбор количества потоков
select_threads() {
    local max_threads=64
    local threads=1

    # Убраны логи в STDOUT при получении ввода
    printf "Копия поддерживает многопоточное восстановление.\n" > /dev/tty

    while true; do
        printf "Введите количество потоков для восстановления (1 - %d): " "$max_threads" > /dev/tty
        read -r threads < /dev/tty

        if [[ "$threads" =~ ^[0-9]+$ ]] && [ "$threads" -ge 1 ] && [ "$threads" -le "$max_threads" ]; then
            break
        else
            printf "Неверный ввод. Пожалуйста, введите число от 1 до %d.\n" "$max_threads" > /dev/tty
            log_only "ОШИБКА: Неверный ввод потоков ($threads)."
        fi
    done

    # Только финальное значение попадает в STDOUT для захвата
    echo "$threads"
}


# ФУНКЦИИ ВОССТАНОВЛЕНИЯ И ПРОВЕРКИ


# Создание базы данных стандарта 1С
create_1c_db() {
    local db_name="$1"

    log "Попытка создания базы данных $db_name..."

    #  Создание БД
    if ! sudo -u postgres "$PG_CREATEDB" -E UTF8 -O postgres "$db_name" >> "$LOG_FILE" 2>&1; then
        log "ОШИБКА: Не удалось создать базу данных $db_name. Проверьте, не существует ли она уже."
        return 1
    fi

    #  Установка параметров (стандарт 1С)
    log "Установка стандартных параметров 1С для $db_name..."
    local psql_commands="
ALTER DATABASE \"$db_name\" SET client_encoding TO 'UTF8';
ALTER DATABASE \"$db_name\" SET standard_conforming_strings TO on;
"
    if ! echo "$psql_commands" | sudo -u postgres "$PG_PSQL" -d "$db_name" >> "$LOG_FILE" 2>&1; then
        log "ОШИБКА: Не удалось установить параметры 1С."
        return 1
    fi

    log "База данных $db_name успешно создана с параметрами 1С."
    return 0
}

# Восстановление из custom/directory (многопоточное)
restore_parallel() {
    local backup_path="$1"
    local target_db="$2"
    local threads="$3"
    local format_flag=""

    if [ -d "$backup_path" ]; then
        format_flag="-Fd" # Directory format
    elif [[ "$backup_path" =~ \.dump$ ]]; then
        format_flag="-Fc" # Custom format
    else
        log "ОШИБКА: Неизвестный тип файла для параллельного восстановления: $backup_path"
        return 1
    fi

    log "Начало многопоточного восстановления ($threads потоков) в $target_db из $backup_path (Формат: $format_flag)..."

    if sudo -u postgres "$PG_RESTORE" $format_flag -j "$threads" -d "$target_db" "$backup_path" >> "$LOG_FILE" 2>&1; then
        log "УСПЕХ: Восстановление $target_db завершено."
        return 0
    else
        log "ОШИБКА: Сбой при восстановлении $target_db. См. лог."
        return 1
    fi
}

# Восстановление из plain/sql.gz
restore_plain() {
    local backup_path="$1"
    local target_db="$2"

    log "Начало однопоточного восстановления в $target_db из $backup_path..."

    if [[ "$backup_path" =~ \.sql\.gz$ ]]; then
        if gzip -dc "$backup_path" | sudo -u postgres "$PG_PSQL" -d "$target_db" >> "$LOG_FILE" 2>&1; then
            log "УСПЕХ: Восстановление $target_db завершено."
            return 0
        fi
    else
        log "ОШИБКА: Неизвестный или не поддерживающийся однопоточный формат."
    fi

    log "ОШИБКА: Сбой при восстановлении $target_db. См. лог."
    return 1
}

# Проверка базы данных после восстановления
verify_db() {
    local db_name="$1"
    log "Проверка подключения и целостности базы данных $db_name..."
    if sudo -u postgres "$PG_PSQL" -d "$db_name" -t -c "SELECT 1" >> "$LOG_FILE" 2>&1; then
        log "База данных $db_name успешно проверена (SELECT 1)."
        return 0
    else
        log "ПРЕДУПРЕЖДЕНИЕ: Проверка $db_name не удалась. База данных может быть повреждена или недоступна."
        return 1
    fi
}


# ОСНОВНОЙ СКРИПТ


log "========================================"
log "PostgreSQL Restore Script"
log "Время начала: $(date +'%d.%m.%Y %H:%M:%S')"
log "========================================"

# Проверка команд
if ! check_commands; then
    exit 1
fi

#  Сканирование и выбор
scan_output=$(scan_local_backups "$BACKUP_PATH")
SOURCE_TYPE="LOCAL"


# Преобразование вывода сканирования в ассоциативный массив
declare -A backup_details
while IFS= read -r line; do
    key=$(echo "$line" | awk '{print $1}')
    value=$(echo "$line" | cut -d ' ' -f 2-)
    backup_details["$key"]="$value"
done <<< "$scan_output"

i=1
backups_list=()
for key in "${!backup_details[@]}"; do
    if [[ "$key" =~ ,db$ ]]; then
        backups_list+=("$i")
        i=$((i + 1))
    fi
done

if [ ${#backups_list[@]} -eq 0 ]; then
    log "ОШИБКА: Не найдено подходящих резервных копий в $BACKUP_PATH."
    exit 1
fi

# СБОР И СОРТИРОВКА ДАННЫХ ДЛЯ ОТОБРАЖЕНИЯ
display_count=0
SORTED_OUTPUT=""

#  Сбор данных в строку с префиксом даты/времени для сортировки
for key in "${!backup_details[@]}"; do
    if [[ "$key" =~ ,path$ ]]; then
        index=$(echo "$key" | cut -d ',' -f 1)
        time="${backup_details["$index,time"]}"
        db="${backup_details["$index,db"]}"
        format="${backup_details["$index,format"]}"

        # Используем YYYYMMDD_HH-MM для корректной сортировки дат в формате DD.MM.YYYY_HH-MM
        SORT_KEY=$(echo "$time" | awk -F '[_.]' '{print $3$2$1"_"$4}')

        SORTED_OUTPUT+="${SORT_KEY}|${index}|${db}|${format}|${time}\n"
    fi
done

#  Сортировка по полю даты/времени (по убыванию, -r)
SORTED_LIST=$(echo -e "$SORTED_OUTPUT" | sort -t '|' -k1 -r)

echo "----------------------------------------------------------------------------"
printf "%-5s | %-20s | %-12s | %s\n" "№" "База" "Формат" "Дата/Время"
echo "----------------------------------------------------------------------------"

#  Вывод отсортированного списка (самые свежие сверху)
IFS=$'\n'
for line in $SORTED_LIST; do
    if [ $display_count -ge $MAX_COPIES_TO_SHOW ]; then
        break
    fi

    # Извлечение данных из отсортированной строки
    index=$(echo "$line" | cut -d '|' -f 2)
    db=$(echo "$line" | cut -d '|' -f 3)
    format=$(echo "$line" | cut -d '|' -f 4)
    time=$(echo "$line" | cut -d '|' -f 5)

    printf "%-5s | %-20s | %-12s | %s\n" "$index" "$db" "$format" "$time"
    display_count=$((display_count + 1))
done
unset IFS

echo "----------------------------------------------------------------------------"

# 3. Выбор копии
while true; do
    read -r -p "Введите номер копии для восстановления (1-$(($i-1))): " selected_index
    if [[ "$selected_index" =~ ^[0-9]+$ ]] && [ -n "${backup_details["$selected_index,path"]}" ]; then
        backup_path="${backup_details["$selected_index,path"]}"
        original_db="${backup_details["$selected_index,db"]}"
        backup_format="${backup_details["$selected_index,format"]}"
        break
    fi
    log "Неверный ввод. Пожалуйста, введите номер из списка."
done

log "Выбрана копия: $original_db (Формат: $backup_format) из $backup_path (Источник: $SOURCE_TYPE)"

#  Обработка tar-архива (распаковка на месте, если выбрана tar-копия)
if [ "$backup_format" == "directory (tar)" ]; then
    log "Обнаружен tar-архив. Распаковка перед восстановлением: $backup_path"

    # Имя директории, куда будет распаковано (имя файла без .tar)
    local extracted_dir="${backup_path%.*}"

    # Проверяем, существует ли уже распакованная директория
    if [ -d "$extracted_dir" ]; then
        log "Директория $extracted_dir уже существует. Используем ее."
    else
        # Распаковываем в ту же папку, где лежит tar-файл ($BACKUP_PATH)
        if ! tar -xf "$backup_path" -C "$BACKUP_PATH" >> "$LOG_FILE" 2>&1; then
            log "ОШИБКА: Не удалось распаковать tar-архив $backup_path."
            exit 7
        fi
        log "Распаковка завершена. Временный путь: $extracted_dir"
        # Добавляем распакованную директорию во временные файлы для очистки при завершении
        TEMP_FILES_TO_CLEANUP+=("$extracted_dir")
    fi

    backup_path="$extracted_dir"
    backup_format="directory" # Формат меняется на directory
fi


# 5. Выбор целевой БД и подготовка
IFS=',' read -r target_db target_action <<< $(select_target_db "$original_db")

# Подготовка целевой БД
if [ "$target_action" == "replace" ]; then
    read -r -p "ВНИМАНИЕ! Вы выбрали восстановление в ту же БД ($original_db). Эта БД будет УДАЛЕНА и создана заново. Вы уверены? (да/нет): " confirm_delete
    if [[ "$confirm_delete" != "да" ]]; then
        log "Операция отменена пользователем."
        exit 0
    fi

    log "Удаление базы данных $original_db..."
    if ! sudo -u postgres "$PG_DROPDB" "$original_db" >> "$LOG_FILE" 2>&1; then
        log "ОШИБКА: Не удалось удалить базу данных $original_db. Проверьте активные подключения."
        exit 2
    fi

    if ! create_1c_db "$target_db"; then
        log "Критическая ошибка при пересоздании базы данных. Отмена."
        exit 3
    fi
elif [ "$target_action" == "new" ]; then
    # Проверка, что имя базы данных не содержит "мусорных" логов
    if [[ "$target_db" =~ ^[a-zA-Z0-9_]+$ ]]; then
        if ! create_1c_db "$target_db"; then
            log "Критическая ошибка при создании новой базы данных. Отмена."
            exit 3
        fi
    else
        log "Критическая ошибка: Переменная \$target_db содержит некорректное значение: $target_db. Отмена."
        exit 3
    fi
fi

# 6. Восстановление
threads=1
if [ "$backup_format" == "custom" ] || [ "$backup_format" == "directory" ]; then
    # Directory и Custom поддерживают многопоточность
    threads=$(select_threads)

    # Дополнительная проверка, что threads - это число
    if ! [[ "$threads" =~ ^[0-9]+$ ]]; then
        log "Критическая ошибка: Переменная \$threads содержит некорректное значение: $threads. Отмена."
        exit 5
    fi

    if ! restore_parallel "$backup_path" "$target_db" "$threads"; then
        verify_db "$target_db"
        exit 4
    fi
elif [ "$backup_format" == "plain" ]; then
    log "Формат 'plain' (.sql.gz) не поддерживает многопоточное восстановление."
    if ! restore_plain "$backup_path" "$target_db"; then
        verify_db "$target_db"
        exit 4
    fi
else
    log "Критическая ошибка: Неизвестный формат бэкапа: $backup_format"
    exit 5
fi

# 7. Финальная проверка
if verify_db "$target_db"; then
    log "ВОССТАНОВЛЕНИЕ УСПЕШНО ЗАВЕРШЕНО в базу данных $target_db!"
    exit 0
else
    log "ВОССТАНОВЛЕНИЕ С ПРЕДУПРЕЖДЕНИЕМ: База данных $target_db не прошла проверку."
    exit 6
fi
