#!/bin/bash

# путь к baseline файлу
BASELINE="baseline"

# перемещение в директорию, где лежит скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# поиск SUID файлов
RESULT="$(find / -perm -4000 2>/dev/null)"

# проверка на существование baseline файла
if [[ ! -f $BASELINE ]]; then

	# проверка на непустой результат поиска SUID файлов
	if [[ -n "$RESULT" ]]; then

		# записать отсортированный результат поиска в baseline файл
		printf '%s\n' "$RESULT" | LC_ALL=C sort -u > "$BASELINE"
		echo "baseline cохранен в $SCRIPT_DIR/$BASELINE"
	fi

else

	# если файл существует, сравниваем полученный результат с содержимым файла
	LC_ALL=C comm -23 \
		<(printf '%s\n' "$RESULT" | LC_ALL=C sort -u) \
		<(LC_ALL=C sort -u "$BASELINE")
fi
