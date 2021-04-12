# Устновка сервера TeamSpeak3

#### обновить систему
```apt-get update -y && apt-get upgrade -y```

#### создать нового пользователя, без возможности входа
```adduser --disabled-login teamspeak```

#### перейти в его домашнюю папку
```cd /home/teamspeak```

#### скачать сервер (свежую ссылку взять [отсюда](https://www.teamspeak.com/ru/downloads/#server))
```wget https://files.teamspeak-services.com/releases/server/3.13.3/teamspeak3-server_linux_amd64-3.13.3.tar.bz2```

#### распаковать файл:
```tar xvf teamspeak3-server_linux_amd64-3.13.3.tar.bz2```

#### переместить всё в домашнюю папку и удалить оригинальные папки:
```cd teamspeak3-server_linux_amd64 && mv * /home/teamspeak && cd .. && rm teamspeak3-server_linux_amd64-3.13.3.tar.bz2```

#### принять лицензионное соглашение
```touch .ts3server_license_accepted```

#### делаем сервис для автозагрузки:
```sudo nano /lib/systemd/system/teamspeak.service```
```bash
[Unit]
Description=TeamSpeak 3 Server
After=network.target
[Service]
WorkingDirectory=/home/teamspeak/
User=teamspeak
Group=teamspeak
Type=forking
ExecStart=/home/teamspeak/ts3server_startscript.sh start inifile=ts3server.ini
ExecStop=/home/teamspeak/ts3server_startscript.sh stop
PIDFile=/home/teamspeak/ts3server.pid
RestartSec=15
Restart=always
[Install]
WantedBy=multi-user.target
```

#### включить для автозагрузки и стартовать сервис:

```bash
systemctl enable teamspeak.service
systemctl start teamspeak.service
# проверить статус:
service teamspeak status
# или
systemctl status teamspeak.service
```

#### смотреть логи + взять ключ админа:
```cat /home/teamspeak/logs/ts3server_*```

#### **если что-то пошло не так, то переустновить весь сервер можно удалив файл базы из основной директории сервера:**
```bash
systemctl stop teamspeak
systemctl status teamspeak
mv ts3server.sqlitedb ts3server.sqlitedb.old
# на всякий случай сохраняем старую копию:
systemctl start teamspeak
systemctl status teamspeak
```
