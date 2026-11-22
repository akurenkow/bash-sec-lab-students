#!/bin/bash

THRESHOLD=$1
SOURCE=$2
REPORT=blocklist.txt

# проверка, что переданы оба аргумента и файл логов существует
if [[ -z $THRESHOLD || ! -f $SOURCE ]]; then
	echo "Использование: $0 <порог попыток> <путь к логу>"
	exit 1
fi

# собрать все IP адреса, с которых были осуществлены неуспешные попытки авторизации в переменную
# отсортировать по убыванию
#FAILED=$(grep "Failed password" "$SOURCE" \
#	| grep -oE 'from [0-9.]+' \
#	| awk '{print $2}' \
#	| sort \
#	| uniq -c \
#	| sort -rn)

FAILED=$(grep -iE "failed password|authentification failure|invalid user|failed login|authentification failed|authenticating user" "$SOURCE" \
    | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}' \
    | grep -vE '^(127\.0\.0\.1|::1|0\.0\.0\.0)$' \
    | sort | uniq -c | sort -rn)

# переместиться в директорию, где лежит скрипт
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
cd $SCRIPT_DIR || exit 1

# вывести на экран дату, порог и пути к файлам
echo "date: $(date +"%Y-%m-%d %H:%M:%S")"
echo "threshold: $THRESHOLD"
echo "source: $SOURCE"
echo "report: $(dirname ${BASH_SOURCE[0]})/$REPORT"
echo

# пересоздать файл отчета и записать в него текущую дату и порог
# date +"%Y-%m-%d %H:%M:%S" > $REPORT
# echo "threshold $THRESHOLD" >> ./$REPORT
# echo "" >> ./$REPORT

# пересоздать файл отчета (пустой)
: > "$REPORT"

# читать элементы попарно из переменной, обойти пары в цикле
while read count ip; do

	[[ -z "$count" ]] && continue
	
	# под условия попадают IP адреса с количеством неуспешных попыток > 5
	if ((count > THRESHOLD)); then

		# вывести на экран сводку по IP адресу
		echo "IP адрес: $ip | попыток входа: $count"
		
		# записать адрес в отчет
		echo "$ip" >> "$REPORT"
	fi
done <<< "$FAILED"
