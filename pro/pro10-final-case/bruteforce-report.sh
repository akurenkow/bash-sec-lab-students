#!/bin/bash

# путь к log файлу
LOG_PATH="$1"

# проверка, что файл логов существует
if [[ ! -f $LOG_PATH ]]; then
	echo "Использование: $0 <путь к логу>"
	exit 1
fi

# сохраняем IP адреса с количеством попыток в переменную
FAILED=$(grep "Failed password" "$LOG_PATH" | grep -oE 'from [0-9.]+' | awk '{ print $2 }' | sort | uniq -c | sort -rn)
ACCEPTED=$(grep "Accepted password" "$LOG_PATH" | grep -oE 'from [0-9.]+' | awk '{ print $2 }' | sort | uniq -c | sort -rn)

# выставляем базовые статус OK и код 0
STATUS="OK"
CODE=0

# в цикле обрабатываем пары IP и количества их попыток, читая из переменной FAILED
while read count ipaddr; do

	# если попыток было не меньше 4
	if [[ "$count" -ge 4 ]]; then

		# выводим IP на экран
		echo "$ipaddr" : "$count" FAILED LOGIN ATTEMPTS
		
		# выставляем статус WARNING и код 1, если статус равен OK
		# статус WARNING не требует обновления, статус CRITICAL не понижаем, если он уже появился
		if [[ "$CODE" == 0 ]]; then
			STATUS="WARNING"
			CODE=1
		fi

		# если попыток было больше 10
		if ((count > 10)); then

			# выводим IP на экран и выставляем статус CRITICAL и код 2
			STATUS="CRITICAL"
			CODE=2
		
		# если с этого адреса была успешная авторизация
		elif grep -iq "$ipaddr" <<< "$ACCEPTED"; then

			# выводим на экран IP и время, когда произошло событие компрометации
			echo "$ipaddr" : SUCCESS LOGIN "$(grep "Accepted password " data/auth.log | grep $ipaddr | awk '{ print $1, $2, $3 }')"

			# выводим IP на экран и выставляем статус CRITICAL и код 2
			STATUS="CRITICAL"
			CODE=2

		fi

	fi

done <<< "$FAILED"

echo
echo STATUS "$STATUS"
exit "$CODE"

