#!/bin/bash
# Переменные для источника, назначения, даты и лог-файла
SOURCE="/home/alex"
BACKUP="/tmp/backup"
DATE=$(date +%d-%m-%Y)
LOG="/home/alex/backup.log" # Полный лог выполнения команды rsync

# Проверяем, существует ли каталог, если нет, то создаем его
mkdir -p "$BACKUP"

# Выполняем резервное копирование и сохраняем лог
rsync -ac --delete --log-file="$LOG" "$SOURCE/" "$BACKUP/backup-$USER-$DATE"

# Проверяем, результат выполнения команды rsync
if [ $? -eq 0 ]; then
    logger -p user.info "Резервное копирование $SOURCE в $BACKUP/backup-$USER-$DATE успешно завершено. Детали в $LOG"
    else
    logger -p user.err "ОШИБКА при резервном копировании $SOURCE. Проверьте $LOG"
fi
