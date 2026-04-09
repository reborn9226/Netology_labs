#!/bin/bash
# Переменные для источника, назначения, даты и лог-файла
SOURCE="/home/alex"
BACKUP="/tmp/Backup"
DATE=$(date +dd-%m-%Y)
LOG="/home/alex/backup.log"

# Проверяем, существует ли каталог, если нет, то создаем его
if [ ! -d "$BACKUP" ]; then
    mkdir -p "$BACKUP"
fi

# Выполняем резервное копирование и сохраняем лог
rsync -ac --delete --log-file="$LOG" "$SOURCE/" "$BACKUP/backup-user-$DATE"

# Проверяем, результат выполнения команды rsync
if [ $? -eq 0 ]; then
    echo "Резервное копирование заверешено успешно. Лог сохранен в $LOG"
    else
    echo "Произошла ошибка при выполнении резервного копрированияя. Проверь лог для подробностей $LOG"
fi

