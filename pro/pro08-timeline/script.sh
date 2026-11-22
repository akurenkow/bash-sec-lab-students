#!/bin/bash
set -euo pipefail
export LC_TIME=C

ACCESS_LOG=$(realpath data/access.log)
AUTH_LOG=$(realpath data/auth.log)
FULL_LOG=""

while IFS= read -r line || [[ -n "$line" ]]; do

	# пропускаем пустые строки
	[[ -z "$line" ]] && continue

	# собираем колонки с датой в переменную
	raw=$(printf '%s\n' "$line" | awk '{print $4, $5}')
	
	# Убираем квадратные скобки и часовой пояс в конце
	clean="${raw//[\[\]]/}"
	clean="${clean% *}"

	# меняем '/' и первое ':' на пробелы -> "19 Nov 2026 10:11:47"
	clean="${clean//\// }"
	clean="${clean/:/ }"

	# FULL_LOG="$FULL_LOG"$(date -d "$clean" +"%Y-%m-%d %H:%M:%S")' [WEB] '$(printf '%s/n' "$line" | awk '{print $1, $6, $7, $9}')$'\n'

	# форматируем дату
    dt=$(date -d "$clean" +"%Y-%m-%d %H:%M:%S")

    # собираем информацию о событии в переменную
    web_info=$(printf '%s\n' "$line" | awk '{print $1, substr($6, 2), $7, $9}')
    
    # дописываем к полному логу событий
    FULL_LOG+="$dt [WEB] $web_info"$'\n'
done < "$ACCESS_LOG"

while IFS= read -r line || [[ -n "$line" ]]; do

	# пропускаем строки без попыток входа по паролю, чтобы grep не уронил скрипт
	[[ "$line" != *"password for"* ]] && continue

	# собираем колонки с датой в переменную
	raw=$(printf '%s\n' "$line" | awk '{print $1, $2, $3}')

	# FULL_LOG="$FULL_LOG"$(date -d "$raw" +"%Y-%m-%d %H:%M:%S")' [SSH] '$(printf '%s/n' "$line" | grep -oE 'from [0-9.]+' | awk '{print $2}')' '$(printf '%s/n' "$line" | grep -oE '(Accepted|Failed) password for (invalid user )?[^ ]+')$'\n'

	# форматируем дату
	dt=$(date -d "$raw" +"%Y-%m-%d %H:%M:%S")
    
    # собираем информацию о событии в переменные
    ip=$(printf '%s\n' "$line" | grep -oE 'from [0-9.]+' | awk '{print $2}')
    msg=$(printf '%s\n' "$line" | grep -oE '(Accepted|Failed) password for (invalid user )?[^ ]+')

    # дописываем к полному логу событий
    FULL_LOG+="$dt [SSH] $ip $msg"$'\n'
done < "$AUTH_LOG"

# выводим полный отсортированный лог событий
printf '%s' "$FULL_LOG" | sort
