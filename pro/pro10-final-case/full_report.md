### С каких IP-адресов были неуспешные попытки входа по SSH и сколько?

Поиск неудачных попыток авторизации по ssh
```
grep "Failed password" pro/pro10-final-case/ssh_auth_training.log \
  | grep -oE 'from [0-9.]+' | awk '{print $2}' \
  | sort | uniq -c | sort -rn
```
Результат:
```
     32 203.0.113.7
      9 198.51.100.23
      1 203.0.113.45
```

### Был ли успешный вход с подозрительного адреса? Когда?

Проверка через поиск событий по IP `203.0.113.7` в выводе timeline.sh
```
pro/pro10-final-case/timeline.sh | grep '203.0.113.7'
```

Результат: множество неудачных попыток входа под разными учетками:
```
2026-11-19 14:00:00 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:01:07 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:02:14 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:03:21 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:04:28 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:05:35 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:06:42 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:07:49 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:08:56 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:10:03 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:11:10 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:12:17 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:13:24 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:14:31 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:15:38 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:16:45 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:17:52 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:18:59 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:20:06 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:21:13 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:22:20 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:23:27 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:24:34 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:25:41 [SSH] 203.0.113.7 Failed password for root
2026-11-19 14:26:48 [SSH] 203.0.113.7 Failed password for invalid user test
2026-11-19 14:27:55 [SSH] 203.0.113.7 Failed password for invalid user support
2026-11-19 14:29:02 [SSH] 203.0.113.7 Failed password for invalid user guest
2026-11-19 14:30:09 [SSH] 203.0.113.7 Failed password for invalid user oracle
2026-11-19 14:31:16 [SSH] 203.0.113.7 Failed password for invalid user oracle
2026-11-19 14:32:23 [SSH] 203.0.113.7 Failed password for invalid user support
2026-11-19 14:33:30 [SSH] 203.0.113.7 Failed password for invalid user test
2026-11-19 14:34:37 [SSH] 203.0.113.7 Failed password for invalid user test
```

Проверка через поиск событий по IP `198.51.100.23` в выводе timeline.sh
```
pro/pro10-final-case/timeline.sh | grep '198.51.100.23'
```

Успешная попытка входа под пользователем `admin` в 15:10:03:
```
2026-11-19 11:25:00 [WEB] 198.51.100.23 GET /products?id=1%27%20OR%20%271%27%3D%271 403
2026-11-19 11:25:48 [WEB] 198.51.100.23 GET /search?q=%27%20UNION%20SELECT%20NULL-- 403
2026-11-19 11:26:36 [WEB] 198.51.100.23 GET /api/products?sort=1%20AND%201%3D1 400
2026-11-19 11:27:24 [WEB] 198.51.100.23 GET /login?next=%27%20OR%20%271%27%3D%271 403
2026-11-19 12:20:00 [SSH] 198.51.100.23 error: maximum authentication attempts exceeded for admin
2026-11-19 12:20:00 [SSH]  Disconnecting authenticating user admin 198.51.100.23 port 52001: Too many authentication failures [preauth]
2026-11-19 14:00:00 [WEB] 198.51.100.23 OPTIONS / 200
2026-11-19 14:05:00 [WEB] 198.51.100.23 TRACE / 405
2026-11-19 14:10:00 [WEB] 198.51.100.23 PUT /uploads/test.txt 403
2026-11-19 14:15:00 [WEB] 198.51.100.23 POST /admin/login 401
2026-11-19 14:20:00 [WEB] 198.51.100.23 GET /.well-known/security.txt 200
2026-11-19 15:00:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:01:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:02:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:03:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:04:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:05:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:06:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:07:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:08:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:10:03 [SSH] 198.51.100.23 Accepted password for admin
```

Проверка на успешный вход в самом логе:
```
cat pro/pro10-final-case/ssh_auth_training.log | grep '198.51.100.23' | grep 'Accepted'
```

Вход был осуществлен:
```
Nov 19 15:10:03 server sshd[4201]: Accepted password for admin from 198.51.100.23 port 51505 ssh2
```

### Что происходило в это время на веб-сервере (access.log)?

Фильтрация в пределах часа по событиям с 15.00:
```
pro/pro10-final-case/timeline.sh | grep ' 15:'
```

Результат:
```
2026-11-19 15:00:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:00:03 [SSH]  session): session closed for user analyst
2026-11-19 15:01:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:02:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:03:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:04:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:05:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:05:06 [SSH] 10.0.0.5 Accepted password for deploy
2026-11-19 15:05:08 [SSH]  session): session opened for user deploy(uid=1001) by (uid=0)
2026-11-19 15:05:24 [WEB] 10.0.0.18 POST /login 401
2026-11-19 15:06:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:07:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:08:00 [SSH] 198.51.100.23 Failed password for admin
2026-11-19 15:10:03 [SSH] 198.51.100.23 Accepted password for admin
2026-11-19 15:10:05 [SSH]  session): session opened for user admin(uid=1000) by (uid=0)
2026-11-19 15:14:09 [WEB] 192.168.1.15 GET /static/style.css 200
2026-11-19 15:14:51 [SSH]  session): session closed for user admin
2026-11-19 15:15:00 [WEB] 10.0.0.18 GET /api/orders 500
2026-11-19 15:18:02 [WEB] 192.168.1.15 GET /about 200
2026-11-19 15:21:01 [WEB] 192.168.1.15 GET /api/products 200
2026-11-19 15:21:42 [WEB] 192.168.1.22 GET /contact 200
2026-11-19 15:22:19 [SSH] 10.0.0.5 Accepted password for analyst
2026-11-19 15:22:20 [SSH]  session): session opened for user analyst(uid=1002) by (uid=0)
2026-11-19 15:23:52 [WEB] 10.0.0.18 POST /login 302
2026-11-19 15:24:00 [WEB] 192.168.1.22 GET /api/products 503
2026-11-19 15:25:15 [SSH] 192.168.1.40 Accepted password for deploy
2026-11-19 15:25:16 [SSH]  session): session opened for user deploy(uid=1001) by (uid=0)
2026-11-19 15:29:42 [WEB] 192.168.1.22 GET /contact 200
2026-11-19 15:30:20 [WEB] 192.168.1.15 GET /about 200
2026-11-19 15:33:00 [WEB] 203.0.113.45 GET /search?q=test 429
2026-11-19 15:34:06 [SSH]  session): session closed for user deploy
2026-11-19 15:40:27 [WEB] 192.168.1.40 GET /index.html 200
2026-11-19 15:42:00 [WEB] 10.0.0.5 GET /checkout 500
2026-11-19 15:42:10 [WEB] 192.168.1.22 GET /robots.txt 200
2026-11-19 15:43:17 [SSH] 192.168.1.15 Accepted password for deploy
2026-11-19 15:43:21 [SSH]  session): session opened for user deploy(uid=1001) by (uid=0)
2026-11-19 15:46:06 [WEB] 10.0.0.18 GET /favicon.ico 304
2026-11-19 15:46:29 [SSH] 192.168.1.22 Accepted password for deploy
2026-11-19 15:46:30 [SSH]  session): session opened for user deploy(uid=1001) by (uid=0)
2026-11-19 15:47:08 [WEB] 10.0.0.18 GET / 200
2026-11-19 15:47:54 [WEB] 192.168.1.40 GET /index.html 200
2026-11-19 15:55:51 [SSH]  session): session closed for user backup
2026-11-19 15:56:17 [WEB] 192.168.1.15 GET /robots.txt 200
2026-11-19 15:57:43 [SSH] 192.168.1.22 Accepted password for analyst
2026-11-19 15:57:45 [SSH]  session): session opened for user analyst(uid=1002) by (uid=0)
2026-11-19 15:58:36 [WEB] 10.0.0.18 POST /login 302
2026-11-19 15:59:40 [WEB] 192.168.1.15 GET /favicon.ico 304

```

### Проверка на обращения к чувствительным путям на веб-сервере

Фильтрация полного таймлайна по ключу `404`
```
pro/pro10-final-case/timeline.sh | grep '404'
```

Результат:
```
2026-11-19 10:42:00 [WEB] 203.0.113.99 GET /admin 404
2026-11-19 10:42:35 [WEB] 203.0.113.99 GET /wp-login.php 404
2026-11-19 10:43:10 [WEB] 203.0.113.99 GET /.env 404
2026-11-19 10:43:45 [WEB] 203.0.113.99 GET /phpmyadmin 404
2026-11-19 10:44:20 [WEB] 203.0.113.99 GET /admin/config.php 404
2026-11-19 10:44:55 [WEB] 203.0.113.99 GET /.git/config 404
2026-11-19 10:45:30 [WEB] 203.0.113.99 GET /backup.sql 404
2026-11-19 10:46:05 [WEB] 203.0.113.99 GET /server-status 404
2026-11-19 10:46:40 [WEB] 203.0.113.99 GET /cgi-bin/ 404
2026-11-19 10:47:15 [WEB] 203.0.113.99 GET /vendor/phpunit/ 404
2026-11-19 10:47:50 [WEB] 203.0.113.99 GET /actuator/env 404
2026-11-19 10:49:00 [WEB] 203.0.113.99 GET /config.php 404
2026-11-19 10:49:35 [WEB] 203.0.113.99 GET /old/ 404
2026-11-19 12:05:22 [WEB] 192.168.1.22 GET /about 404
2026-11-19 13:16:00 [WEB] 203.0.113.45 GET /index.php?page=%2Fetc%2Fpasswd 404
```
События, привлекающие внимание: 
1. Попытка прочитать пароли в 13:16:00 с `203.0.113.45`
2. Множественные обращения к "чувствительным" путям с `203.0.113.99`

Проверка полного лога действий с IP `203.0.113.45`
```
pro/pro10-final-case/timeline.sh | grep '203.0.113.45'
```

Результат:
```
2026-11-19 11:07:03 [SSH]  Connection closed by 203.0.113.45 port 44901 [preauth]
2026-11-19 11:08:19 [SSH] 203.0.113.45 Did not receive identification string
2026-11-19 13:05:42 [SSH] 203.0.113.45 Failed publickey for deploy
2026-11-19 13:06:10 [SSH] 203.0.113.45 Invalid user postgres
2026-11-19 13:06:11 [SSH] 203.0.113.45 Failed password for invalid user postgres
2026-11-19 13:10:00 [WEB] 203.0.113.45 GET /download?file=..%2F..%2F..%2Fetc%2Fpasswd 403
2026-11-19 13:13:00 [WEB] 203.0.113.45 GET /view?page=..%2F..%2Fetc%2Fshadow 403
2026-11-19 13:16:00 [WEB] 203.0.113.45 GET /index.php?page=%2Fetc%2Fpasswd 404
2026-11-19 13:19:00 [WEB] 203.0.113.45 GET /search?q=%3Cscript%3Ealert(1)%3C%2Fscript%3E 403
2026-11-19 13:22:00 [WEB] 203.0.113.45 GET /api/ping?host=127.0.0.1%3Bwhoami 400
2026-11-19 13:25:00 [WEB] 203.0.113.45 POST /api/import 413
2026-11-19 15:33:00 [WEB] 203.0.113.45 GET /search?q=test 429
```

Проверка полного лога действий с IP `203.0.113.99`
```
pro/pro10-final-case/timeline.sh | grep '203.0.113.99'
```

Результат:
```
2026-11-19 10:42:00 [WEB] 203.0.113.99 GET /admin 404
2026-11-19 10:42:35 [WEB] 203.0.113.99 GET /wp-login.php 404
2026-11-19 10:43:10 [WEB] 203.0.113.99 GET /.env 404
2026-11-19 10:43:45 [WEB] 203.0.113.99 GET /phpmyadmin 404
2026-11-19 10:44:20 [WEB] 203.0.113.99 GET /admin/config.php 404
2026-11-19 10:44:55 [WEB] 203.0.113.99 GET /.git/config 404
2026-11-19 10:45:30 [WEB] 203.0.113.99 GET /backup.sql 404
2026-11-19 10:46:05 [WEB] 203.0.113.99 GET /server-status 404
2026-11-19 10:46:40 [WEB] 203.0.113.99 GET /cgi-bin/ 404
2026-11-19 10:47:15 [WEB] 203.0.113.99 GET /vendor/phpunit/ 404
2026-11-19 10:47:50 [WEB] 203.0.113.99 GET /actuator/env 404
2026-11-19 10:48:25 [WEB] 203.0.113.99 GET /api/swagger.json 403
2026-11-19 10:49:00 [WEB] 203.0.113.99 GET /config.php 404
2026-11-19 10:49:35 [WEB] 203.0.113.99 GET /old/ 404
2026-11-19 14:25:00 [WEB] 203.0.113.99 GET /admin 200
```

### Ваша оценка: инцидент или ложная тревога? Что предложите сделать первым делом (2–3 меры)?

Рекомендация: 

1. Блокировка адресов фаерволом:
- 203.0.113.7 (попытки входа под разными учетками)
- 203.0.113.99 (обращения к чувствительным путям)
- 203.0.113.45 (попытки подбора паролей к системным пользователям + сканирование)
- 198.51.100.23 (успешная авторизация под admin после серии неудачных попыток)

2. Изоляция хоста
3. Сброс паролей
4. Проверка на persistence (новые ключи, пользователи, крон-джобы).