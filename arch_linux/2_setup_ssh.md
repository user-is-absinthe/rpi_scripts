# Конфигурация SSH-сервера

### Проверка работы службы

```bash
sshd -t
```

Отсутствие вывода означает рабочую конфигурацию.

### Попрвить настройки в ```/etc/ssh/sshd_config```

```bash
nano /etc/ssh/sshd_config
```

```bash
Здесь должны быть пункты, что куда крутить, но я их не помню и там было
всё интуитвно. Но смотреть в сторону "разрешения логина по паролю" и
"списка разрешенных хостов".
```

### Перезапустить службу и добавить её в автозагрузку

```bash
 systemctl enable sshd.service  # добавление в автозагрузку
 systemctl start sshd.service   # запуск службы
 systemctl restart sshd.service # перезапуск службы
```

### Проверка статуса

```bash
 systemctl status sshd.service
```

```bash
* sshd.service - OpenSSH Daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2021-03-16 19:28:42 UTC; 1 day 2h ago
   Main PID: 228 (sshd)
      Tasks: 1 (limit: 232)
     CGroup: /system.slice/sshd.service
             `-228 sshd: /usr/bin/sshd -D [listener] 0 of 10-100 startups

Mar 16 19:28:42 alarmpi systemd[1]: Started OpenSSH Daemon.
Mar 16 19:28:44 alarmpi sshd[228]: Server listening on 0.0.0.0 port 22.
Mar 16 19:58:47 alarmpi sshd[405]: pam_systemd_home(sshd:account): systemd-homed is not available: Unit dbus-org.freedeskt>
Mar 16 19:58:47 alarmpi sshd[405]: Accepted password for alarm from 192.168.1.113 port 61220 ssh2
Mar 16 19:58:47 alarmpi sshd[405]: pam_unix(sshd:session): session opened for user alarm(uid=1000) by (uid=0)
Mar 16 19:58:47 alarmpi sshd[405]: pam_env(sshd:session): deprecated reading of user environment enabled
```

---

Материал взят с
[вики](https://wiki.archlinux.org/index.php/OpenSSH_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)#%D0%A1%D0%B5%D1%80%D0%B2%D0%B5%D1%80).
