# Настройка нового удаленного сервера

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
Login GraceTime 30
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
sudo systemctl restart ssh
# CentOS/Fedora
sudo service sshd restart
```
- при необходимости установить сетевые утилиты, в частности, ifconfig:
```
apt install net-tools
```
