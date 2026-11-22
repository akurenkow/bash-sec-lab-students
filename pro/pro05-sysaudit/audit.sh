#!/bin/bash

REPORT_PATH="report.md"
DATE="$(date +"%Y-%m-%d %H:%M:%S")"

put_to_report() {

	if [[ -n "$1" ]]; then
		echo "" >> "$REPORT_PATH"
		echo "$2": >> "$REPORT_PATH"
		printf '%s\n' "$1" >> "$REPORT_PATH"

	fi

}

# переместиться в директорию, где лежит скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# очистить файл отчета и записать в него дату
echo '###' "$DATE" > "$REPORT_PATH"

# сохранить всех пользователей с UID 0 в файл отчета
UID0_USERS="$(awk -F: '$3 == 0 {print $1}' /etc/passwd)"
put_to_report "$UID0_USERS" 'root users'

# сохранить всех пользователей с UID >= 1000 в файл отчета
UID1000_USERS="$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)"
put_to_report "$UID1000_USERS" 'UID 1000 users'

# сохранить root-процессы не из системных путей в файл отчета
ROOT_PROCS="$(ps -u root -o pid,user,comm,args | awk 'NR>1 && $4 ~ /^\// && $4 !~ /^\/(usr\/)?(local\/)?(s?bin|lib|libexec)\// {print}')"
put_to_report "$ROOT_PROCS" 'root processes'

# сохранить открытые порты в файл отчета
OPENED_PORTS="$(ss -tulpnH | awk '{print $5}' | awk -F':' '{print $NF}' | sort -nu)"
put_to_report "$OPENED_PORTS" 'opened ports'

# сохранить файлы без владельца в файл отчета
NOUSER_FILES="$(find /tmp -nouser 2>/dev/null)"
put_to_report "$NOUSER_FILES" 'no user files'