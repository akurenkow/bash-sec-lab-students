#!/bin/bash
set -euo pipefail
export LC_TIME=C

ACCESS_LOG=$(realpath data/access.log)
AUTH_LOG=$(realpath data/auth.log)

# В syslog нет года — задаём его вручную (или берём из имени/текущей даты)
LOG_YEAR="${LOG_YEAR:-2026}"

# WEB-лог (apache/nginx): [19/Nov/2026:14:16:52 +0300]
process_web() {
    awk '
    BEGIN { split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", m, " "); for (i=1;i<=12;i++) mon[m[i]]=i }
    NF == 0 { next }
    {
        raw = $4 " " $5
        gsub(/[\[\]]/, "", raw)
        sub(/ [^ ]+$/, "", raw)              # убрать часовой пояс
        split(raw, p, /[\/:]/)               # 19 Nov 2026 14 16 52
        ts = mktime(p[3]" "mon[p[2]]" "p[1]" "p[4]" "p[5]" "p[6])
        printf "%s [WEB] %s %s %s %s\n", strftime("%Y-%m-%d %H:%M:%S", ts), $1, substr($6, 2), $7, $9
    }' "$1"
}

# SSH-лог (syslog): Nov 19 14:16:52 server sshd[...]: Failed password for invalid user root from 203.0.113.7 port ...
# Извлекаем: дату, IP, текст сообщения. Год подставляем из LOG_YEAR.
process_ssh() {
    awk -v year="$1" '
    BEGIN { split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", m, " "); for (i=1;i<=12;i++) mon[m[i]]=i }
    NF == 0 { next }
    {
        split($3, t, ":")
        ts = mktime(year" "mon[$1]" "$2" "t[1]" "t[2]" "t[3])
        if (ts < 0) next

        # берём всё после последнего ": " (это уже чистое сообщение)
        msg = $0
        sub(/^.*sshd[^:]*:[ ]*/, "", msg)

        # IP: "from X.X.X.X"
        ip = ""
        if (match(msg, /from [0-9.]+/))
            ip = substr(msg, RSTART+5, RLENGTH-5)

        # обрезаем хвост " from ... port ... ssh2"
        sub(/ from [0-9.]+ port [0-9]+.*$/, "", msg)

        printf "%s [SSH] %s %s\n", strftime("%Y-%m-%d %H:%M:%S", ts), ip, msg
    }' "$2"
}

FULL_LOG="$(process_ssh "$LOG_YEAR" "$AUTH_LOG")"

FULL_LOG+=$'\n'"$(process_web "$ACCESS_LOG")"

printf '%s\n' "$FULL_LOG" | sed '/^$/d' | sort