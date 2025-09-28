# Настройка нового удаленного сервера

### Переделал всё под скрипт, [скрипт лежит здеся](https://github.com/user-is-absinthe/rpi_scripts/blob/master/remote_server/firstsetup_newvps.sh).

#### сменить пароль root
```passwd```

#### создать пользователя
```adduser user```

#### включить его в sudo
```usermod -aG sudo user```
#### проверить доступность
- переход в оболочку пользователя
```su - user```
- повышение привелегий из-под пользователя
```sudo su```
- выход из сессии
```^D```

#### перенести открытый ключ для root в обычного пользователя и сменить ему владельца:
```bash
mkdir /home/user/.ssh
cp /root/.ssh/authorized_keys /home/user/.ssh/
chown -R user:user /home/user/.ssh
```

### **!!! проверить вход по новому пользователю и права sudo для него !!!**

#### настройка ssh:
- копирование файла настроек
```cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old```
- редактирование файла настроек
```nano /etc/ssh/sshd_config```
```bash
Port 22540
LoginGraceTime 30
	# Login GraceTime
	# По умолчанию, при подключении к серверу по ssh у пользователя есть 2 минуты для ввода логина и пароля. Такого промежутка более чем достаточно, причем не только для авторизованного пользователя, но и для хакера. Поэтому время ожидания ввода этих данных стоит ограничить до 30-60 секунд, в зависимости от ваших предпочтений.
PasswordAuthentication no
# Отключить вход для рута:
PermitRootLogin no
```
### ! Настройка для MobaXterm, включающая небезопасный (старый) алгоритм SHA-1 ([источник](https://superuser.com/questions/1678830/server-refused-our-key-only-from-mobaxterm-bookmark-setup)):

- добавить в файл конфигурации следующую строку:

```
PubkeyAcceptedKeyTypes +ssh-rsa
```

- сохранить и перезапустить сервис
```bash
# Ubuntu/Debian
systemctl restart ssh
```
- при необходимости установить утилиты, в частности, ifconfig и ufw (Uncomplicated Firewall):
```
apt install net-tools -y
apt install ufw -y
```

- Шпаргалка по ufw:
```bash
# проверить что там по правилам
ufw status

# включить/выключить и одновременно добавить в автозагрузку
ufw enable
ufw disable

# разрешить слушать какой-то порт, при такой нотации открывается ipv4 и ipv6 сразу по протоколам TCP и UDP
ufw allow 22 comment "ssh here"
ufw delete allow 22

# разрешаем перенаправление
ufw route allow in on wg0 out on ens3 comment "allow wg0 redirect"
ufw route delete allow in on wg-swe out on ens3

```
