tail -f data/auth.log | grep --line-buffered "Failed password"
Nov 19 15:01:22 server sshd[411]0: Failed password for admin from 198.51.100.23 port 51796 ssh2
Nov 19 15:02:22 server sshd[412]0: Failed password for admin from 198.51.100.23 port 51838 ssh2
Nov 19 15:03:22 server sshd[413]0: Failed password for admin from 198.51.100.23 port 51217 ssh2
Nov 19 15:04:22 server sshd[414]0: Failed password for admin from 198.51.100.23 port 51798 ssh2
Nov 19 15:05:22 server sshd[415]0: Failed password for admin from 198.51.100.23 port 51649 ssh2
Nov 19 15:06:22 server sshd[416]0: Failed password for admin from 198.51.100.23 port 51868 ssh2
Nov 19 15:07:22 server sshd[417]0: Failed password for admin from 198.51.100.23 port 51373 ssh2
Nov 19 15:08:22 server sshd[418]0: Failed password for admin from 198.51.100.23 port 51887 ssh2
Nov 19 23:59:59 server sshd[9999]: Failed password for root from 10.9.9.9 port 1234 ssh2
Nov 19 23:59:59 server sshd[9999]: Failed password for root from 10.9.9.9 port 1234 ssh2

### почему Accepted-строка не показалась?

Потому, что не попала под критерий фильтра команды grep.

### Как это использует дежурная смена SOC?

Дежурная смена SOC использует это как сигнал для триажа. Дальше ищется событие успешного входа, свидетельствующее об инциденте компрометации. 
Если успеха нет, то это шум (хотя, и требующий блокировки на фаерволе).
Если успех был, требуется изоляция хоста, сброс паролей, проверка на наличие новых пользователей, ключей, крон-джоб.
