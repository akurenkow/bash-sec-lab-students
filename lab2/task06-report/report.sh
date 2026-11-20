#!/usr/bin/env bash
# report.sh — мини-отчёт по логу аутентификации
set -euo pipefail

LOG="${1:-data/auth.log}"

echo "===== ОТЧЁТ ПО АУТЕНТИФИКАЦИИ ====="
echo "Дата отчёта: $(date)"
echo "Лог: $LOG"
echo

echo "Всего неудачных входов:"
# ВПИШИТЕ команду подсчёта строк с Failed password:
grep "Failed password" data/auth.log | wc -l

echo
echo "Всего успешных входов:"
# ВПИШИТЕ команду подсчёта строк с Accepted:
grep "Accepted password" data/auth.log | wc -l

echo
echo "Топ-3 атакующих IP:"
# ВПИШИТЕ конвейер (grep Failed → awk IP → топ):
grep "Failed password" data/auth.log   | grep -oE 'from [0-9.]+' | awk '{print $2}' | sort | uniq -c | sort -rn

echo
echo "Успешные входы НЕ с доверенных адресов 192.168.1.*:"
# ВПИШИТЕ: Accepted, но БЕЗ 192.168.1 (подсказка: grep -v — инверсия):
grep "Accepted password" data/auth.log | grep -v "192.168.1." | wc -l
