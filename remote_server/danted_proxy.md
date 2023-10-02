# Настройка danted (SOCKS-5) proxy

#### обновляем систему
```bash
apt update
apt install dante-server
```

#### копируем файл настроек
```mv /etc/danted.conf /etc/danted.conf.old```

```nano /etc/danted.conf```

#### Настройки берем аналогичные
```@bash
logoutput: /var/log/socks.log
# usially port - 53 or 443
internal: %interface_name% port = %port%
external: %interface_name%
clientmethod: none
# socksmethod: none
socksmethod: username
user.privileged: root
user.notprivileged: nobody
user.unprivileged: nobody
user.libwrap: nobody

client pass {
        from: 0/0 to: 0/0
        log: error connect disconnect
}
socks pass {
        from: 0/0 to: 0/0
        command: bind connect udpassociate
        log: error connect disconnect
        socksmethod: username
}
```

при запуске выдает ошибку, надо поправить файл 
```nano /lib/systemd/system/danted.service```
а именно убрать из ReadOnly "var":
```bash
#ReadOnlyDirectories=/bin /etc /lib -/lib64 /sbin /usr /var
ReadOnlyDirectories=/bin /etc /lib -/lib64 /sbin /usr
```

#### Тестирование (выдаст ошибку):
```curl -x socks5://<your_ip_server>:<your_danted_port> ifconfig.co```

#### Далее, создадим пользователя
```useradd duser -r --shell /usr/sbin/nologin```
```passwd duser```
-r - создается системный пользователь
--shell /usr/sbin/nologin - у нового пользователя не будет доступа к cmd

#### Тестирование:
```curl -x socks5://<your_username>:<your_password>@<your_ip_server>:<your_danted_port> ifconfig.co```
