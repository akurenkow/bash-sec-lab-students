#!/bin/bash

# без этой команды:
# 	- ошибки в пайплайнах (grep, sort и т.п.) молча игнорируются;
# 	- обращение к необъявленной переменной даёт пустую строку вместо ошибки;
# 	- падение команды в середине скрипта не останавливает выполнение.
set -euo pipefail

# проверка аргументов
if [[ $# -ne 2 ]]; then
    echo "Использование: $0 <порог попыток> <путь к логу>" >&2
    exit 1
fi
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: порог должен быть неотрицательным целым числом" >&2
    exit 1
fi
if [[ ! -f "$2" || ! -r "$2" ]]; then
    echo "Ошибка: файл лога '$2' не существует или недоступен для чтения" >&2
    exit 1
fi

THRESHOLD="$1"
SOURCE="$(realpath "$2")"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LOG=$(realpath "$SCRIPT_DIR/blocklist.log")
REPORT=$(realpath "$SCRIPT_DIR/blocklist.txt")

# функция логирования
log() {
	local IFS=' '
    printf '%s %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

# обработчик ошибок
# зарегистрировать команду, которая выполнится автоматически, когда любая команда в скрипте завершится с ненулевым кодом возврата
trap 'log "ERROR: exit code $? at line $LINENO"' ERR

log "START: threshold=$THRESHOLD source=$SOURCE user=$(id -un)"

# пересоздать файл отчета и назначить ему права
: > "$REPORT"
chmod 700 "$REPORT"

# пересоздать файл лога и назначить ему права
: > "$LOG"
chmod 700 "$LOG"

# собрать статистику по неудачным попыткам авторизации в переменную
FAILED=$(grep -iE "failed password|authentication failure|invalid user|failed login|authentication failed|authenticating user" "$SOURCE" \
  | grep -oE 'from [0-9.]+' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -rn)

# вывести на экран дату, порог и пути к файлам
echo "date: $(date +"%Y-%m-%d %H:%M:%S")"
echo "threshold: $THRESHOLD"
echo "source: $SOURCE"
echo "report: $REPORT"
echo "log: $LOG"
echo

# счетчик
blocked_count=0

# читать элементы попарно из переменной, обойти пары в цикле
while read -r count ip; do

	# пропустить пустую строку
    [[ -z "${count:-}" ]] && continue

    # сравнение количества вхождений с заданным порогом
    if (( count > THRESHOLD )); then
        echo "IP адрес: $ip | попыток входа: $count"
        echo "$ip" >> "$REPORT"

        # логирование
        log "BLOCKED: ip=$ip attempts=$count"

        # увеличение счетчика
        blocked_count=$((blocked_count + 1))
    fi
done <<< "$FAILED"

# логирование
log "DONE: blocked=$blocked_count report=$REPORT"
