#!/bin/bash
# Переменные
FILE=/var/www/html/index.html
HOST="localhost"
PORT=80

# Счетчик ошибок
ERRORS=0

# Проверка доступности порта
if nc -z -w3 "$HOST" "$PORT" 2>/dev/null; then
    echo "Порт открыт"
else
    echo "Порт закрыт"
    ((ERRORS++))
fi

# Проверка наличия файла index.html
if [ -f "$FILE" ]; then
    echo "Файл существует"
else
    echo "Файл не найден"
    ((ERRORS++))
fi

# Итог проверки
if [ $ERRORS -eq 0 ]; then
    echo "Все хорошо, без ошибок"
    exit 0
else
    echo "Обнаружены ошибки: $ERRORS ошибок"
    exit 1
fi
