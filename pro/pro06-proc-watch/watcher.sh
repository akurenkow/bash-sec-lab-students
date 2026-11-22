#!/bin/bash

# проверка аргумента
if [[ -z "$1" ]]; then
	echo "Использование: $0 <период проверки>" >&2
	exit 1
fi

WHITELIST=whitelist
PERIOD="$1"
DETECTED=""

# переместиться в директорию, где лежит скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# функция вывода процессов, исключая дочерние группы процессов (чтобы команды скрипта не детектились)
# awk отбрасывает сам скрипт и любые запущенные им дочерние процессы
get_procs() {
	ps -eo pgid,user,comm,args | awk -v self="$$" '
		NR>1 && $1 != self && $4 !~ /^\[.*\]$/ && $4 !~ /^\/(usr\/)?(local\/)?(s?bin|lib|libexec)\// {
			sub(/^[[:space:]]*[0-9]+[[:space:]]+/, "")
			print
		}'
}

# записать первый проход в whitelist
get_procs > "$WHITELIST"

# бесконечный цикл проверки и сравнения текущего состояния с whitelist с заданным интервалом
while true; do
	sleep "$PERIOD"
	
	# сохранить разницу между объединенным списком (whitelist + DETECTED) в переменную NEW_PROCS
	# DETECTED нужен, чтобы выводить процесс на экран 1 раз, а не печатать в каждом проходе цикла
	NEW_PROCS=$(LC_ALL=C comm -23 \
		<(get_procs | LC_ALL=C sort -u) \
		<( { cat "$WHITELIST"; printf '%s\n' "$DETECTED"; } | LC_ALL=C sort -u ))

	# если нашлись новые запущенные процессы, вывести их на экран и добавить в DETECTED
	if [[ -n "$NEW_PROCS" ]]; then
		printf '%s\n' "$NEW_PROCS"
		DETECTED+=$'\n'"$NEW_PROCS"
	fi

done