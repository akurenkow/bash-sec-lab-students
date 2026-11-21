#!/bin/bash

# включает обработку шаблонов для корректной работы со скрытыми файлами
shopt -s dotglob nullglob

# проверка аргумента
if [[ -z "$1" || ! -d "$1" ]]; then
	echo "Использование: $0 <абсолютный путь к директории>" >&2
	exit 1
fi

# Преобразуем путь в абсолютный, чтобы корректно работать после cd
DIR_PATH="$(realpath "$1")"

# переместиться в директорию, где лежит скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Генерируем уникальное имя файла дампа для конкретной директории (чтобы не путать разные папки)
SAFE_NAME="$(printf '%s' "$DIR_PATH" | sha256sum | cut -c1-12)"
SHA_SUMS="sha_sums_${SAFE_NAME}"
TMP_SUMS="${SHA_SUMS}_tmp"

# функция создания файла с дампом SHA256 сумм файлов в указанной директории
create_sha_file() {

	local target_dir="$1"
	local out_file="$2"
	
	# Очищаем/создаём файл перед записью
	: > "$out_file"

	# итерация по всем файлам в директории
	for item in "$target_dir"/*; do

		# пропуск директорий и симлинков
		[[ -f "$item" && ! -L "$item" ]] || continue
		
		# запись SHA256 суммы в файл
		sha256sum "$item" >> "$out_file"

	done
}

# проверка на существование файла с дампом SHA256 сумм файлов в указанной директории
if [[ ! -f "$SHA_SUMS" ]]; then

	# вызов функии и создание первичного дампа
	create_sha_file "$DIR_PATH" "$SHA_SUMS"

	echo
	echo "Первичный дамп SHA256 для '$DIR_PATH' сохранен в: $SCRIPT_DIR/$SHA_SUMS"
else
	echo "Сравниваю SHA256 суммы для '$DIR_PATH' с файлом: $SCRIPT_DIR/$SHA_SUMS"

	# удаление временного файла при прерывании скрипта (Ctrl+C)
	trap 'rm -f "$TMP_SUMS"' EXIT

	# вызов функии и создание временного дампа для сравнения с первичным
	create_sha_file "$DIR_PATH" "$TMP_SUMS"
	
	# сравнение
	if diff -u --color "$SHA_SUMS" "$TMP_SUMS"; then
		echo "Изменений не обнаружено."
	fi

fi
