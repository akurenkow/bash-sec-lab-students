Команда:

```
awk '$9 == 404 {print $1}' data/access.log | uniq -c | sort -rn | head -5
```

Вывод:

```
      8 203.0.113.99
```
