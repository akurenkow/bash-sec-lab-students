#!/bin/bash

LOG_PATH="$1"

# проверка, что файл логов существует
if [[ ! -f $LOG_PATH ]]; then
	echo "Использование: $0 <путь к логу>"
	exit 1
fi

# сохраняем IP адреса с количеством попыток в переменную
FAILED=$(grep "Failed password" "$LOG_PATH" | grep -oE 'from [0-9.]+' | awk '{ print $2 }' | sort | uniq -c | sort -rn)
ACCEPTED=$(grep "Accepted password" "$LOG_PATH" | grep -oE 'from [0-9.]+' | awk '{ print $2 }' | sort | uniq -c | sort -rn)


STATUS="OK"
CODE=0

while read count ipaddr; do
	if [[ count -ge 4 ]]; then
		echo "$ipaddr" : "$count" FAILED LOGIN ATTEMPTS
		STATUS="WARNING"
		CODE=1

		if ((count > 10)); then
			STATUS="CRITICAL"
		elif grep -iq "$ipaddr" <<< "$ACCEPTED"; then

			echo "$ipaddr" : SUCCESS LOGIN "$(grep "Accepted password " data/auth.log | grep $ipaddr | awk '{ print $1, $2, $3 }')"

			STATUS="CRITICAL"
			CODE=2
			echo
			echo STATUS "$STATUS"
			exit "$CODE"
		fi

	fi

done <<< "$FAILED"

echo
echo STATUS "$STATUS"
exit "$CODE"

