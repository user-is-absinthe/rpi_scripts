## Создание службы systemctl из питоноскрпита

### 1. Создаем скрипт

```bash
sudo nano /usr/bin/0_users_scripts/test_service.py
```

```python
#!/usr/bin/python3

print('Hell word!')
```

### 2. Создаем файл службы

Он должен иметь расширение ```*.service``` и находиться в ```/lib/systemd/system/```

```bash
sudo nano /lib/systemd/system/test_py_script.service
``` 

```bash
[Unit]
Description=Сюда вписать описание сервиса, можно на русском
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/bin/0_users_scripts/test_service.py
StandardInput=tty-force

[Install]
WantedBy=multi-user.target
```

### 3. Активируем сервис

Для начала перезагрузить демона:

```bash
sudo systemctl daemon-reload
```

Затем добавить службу в автозагрузку:

```bash
sudo systemctl enable test_py_script.service
```

И включить её сейчас:

```bash
sudo systemctl start test_py_script.service
```

### 4. Проверка состояния, запуск, остановка

Соответственно выполняется при помощи:

```bash
sudo systemctl status test_py_script.service        # To get status service
sudo systemctl stop test_py_script.service          # To stop running service 
sudo systemctl start test_py_script.service         # To start running service 
sudo systemctl restart test_py_script.service       # To restart running service 
```

---

Вольный перевод [этой](https://tecadmin.net/setup-autorun-python-script-using-systemd/) статьи,
так же почитать про автоматический перезапуск сервиса можно [тут](https://ma.ttias.be/auto-restart-crashed-service-systemd/).