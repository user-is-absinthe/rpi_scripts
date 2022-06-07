### Стоп & старт:
```wg-quick up wg0```
```wg-quick down wg0```

### Добавление нового устройства:
1. Создать папочку в ключах:
```mkdir {последний октет IP}_{название устройства}```

2. Перейти в нее и создать там открытый и закрытый ключи:
```wg genkey | tee private.key |  wg pubkey > public.key```
```cat private.key```
```cat public.key```

3. Создать файл конфигурации пира:
```nano conf.conf```
```bash
[Interface]
PrivateKey = {private.key пира}
Address = 10.8.0.{ЦИФРА ПРИСВОЕННОГО IP}/24
DNS = 8.8.8.8

[Peer]
PublicKey = {pub.key сервера}
AllowedIPs = 0.0.0.0/0
Endpoint = {IP сервера}:{port сервера}
```

4. Экспортировать как QR:
```qrencode -t ansiutf8 < conf.conf```

5. Добавить устройство в конфиг сервера:
```wg set wg0 peer {pub.key пира} allowed-ips 10.8.0.{ЦИФРА ПРИСВОЕННОГО IP}```

6. Ну и удалить если что:
```wg set wg0 peer {pub.key пира} remove```
