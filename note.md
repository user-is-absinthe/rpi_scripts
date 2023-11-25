Пользовательские скрипты хранятся в
/usr/bin/0_users_scripts/

Активное охлаждение:
	active_fun.service
	display.service

Питоноскрипт as service:
	https://tecadmin.net/setup-autorun-python-script-using-systemd/

sudo systemctl start/stop/status service

----

Если !!!после устновки  NetworkManager!!! опять какой-то затык с DNS, а сеть при этом есть, то:
```bash
nano /etc/systemd/resolved.conf
```

Добавить/раскомментировать туда строку про DNS в категорию ```[Resolve]```: ```DNS=192.168.4.1 9.9.9.9 1.1.1.1 4.4.4.4 8.8.8.8```. Разделение именно через "пробел".

Перезагрузить ```systemd-resolved```:
```bash
service systemd-resolved restart
```

Обрадоваться жизни.



