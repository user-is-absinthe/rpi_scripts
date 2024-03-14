# Настройка danted (SOCKS-5) proxy

#### обновляем систему
```bash
apt update
apt install dante-server
```

#### копируем файл настроек
```bash
mv /etc/danted.conf /etc/danted.conf.old
```

```bash
nano /etc/danted.conf
```

#### Настройки берем аналогичные
```@bash
logoutput: /var/log/socks.log
# usially port - 53 or 443
internal: 0.0.0.0 port=%port%
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

Если при запуске выдает ошибку, надо поправить файл 
```bash
nano /lib/systemd/system/danted.service
```

а именно убрать из ReadOnly "var":
```bash
#ReadOnlyDirectories=/bin /etc /lib -/lib64 /sbin /usr /var
ReadOnlyDirectories=/bin /etc /lib -/lib64 /sbin /usr
```

#### Далее, создадим пользователя
```bash
useradd your_dante_user -r --shell /usr/sbin/nologin
```

```bash
passwd your_dante_user
```

-r - создается системный пользователь

--shell /usr/sbin/nologin - у нового пользователя не будет доступа к cmd

или 

-s /bin/false - аналогично верхней команде

#### Разрешить файрволу пропускать трафик:

```bash
ufw allow %port% comment "danted here"
```

#### Тестирование с авторизацией:
```bash
curl -v -x socks5://%your_dante_user%:%your_dante_password%@%your_server_ip%:%your_dante_port% https://ifconfig.me/
```

#### Управление службой:
```bash
systemctl status danted
```

