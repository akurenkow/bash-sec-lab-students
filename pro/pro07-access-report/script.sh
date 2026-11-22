#!/bin/bash
set -euo pipefail

# проверка аргумента
if [[ -z "$1" || ! -f "$1" ]]; then
	echo "Использование: $0 <путь к лог-файлу>" >&2
	exit 1
fi

LOG_FILE=$(realpath "$1")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_FILE="$SCRIPT_DIR/report.md"

# топ-5 IP адресов, с которых осуществлялись запросы
TOP_5_IP=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5 | column -t -N "COUNT,IP")

# распределение кодов ответа
CODES=$(awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -rn | column -t -N "COUNT,STATUS")

# топ-5 запрошенных путей
TOP_5_PATHS=$(awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5 | column -t -N "COUNT,PATH")

# запросы к "чувствительным" путям с IP и временем
WARN_PATHS=$(awk 'tolower($7) ~ /(\/admin|\.env|\.git|backup)/ {print $1, $4 $5, $7}' "$LOG_FILE" | column -t -N "IP,TIME,PATH")

# Запись отчета с блоками кода для корректного отображения в Markdown
cat << EOF > "$REPORT_FILE"
### Top 5 IP addresses:
\`\`\`text
$TOP_5_IP
\`\`\`

### Response codes quantities:
\`\`\`text
$CODES
\`\`\`

### Top 5 requested paths:
\`\`\`text
$TOP_5_PATHS
\`\`\`

### Sensitive paths:
\`\`\`text
${WARN_PATHS:-No matches found}
\`\`\`
EOF

echo "Отчет успешно сохранен в $REPORT_FILE"
