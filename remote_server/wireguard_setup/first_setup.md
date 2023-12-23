# Настройка WireGuard сервера и клиентов

*Все команды выполняются из-под рута.*

#### Установить WireGuard:
```apt install wireguard -y```

#### Добавить в конец файла ```/etc/sysctl.conf``` строчку перенаправления трафика:
```net.ipv4.ip_forward=1```
Или найти ее там и раскомментировать.
Перезагруть sysctl:
```sysctl -p```

#### Перейти в папку ```/etc/wireguard```, создать там для удобства папочку с ключами, создать в ней подпапку с ключами сервера, перейти в нее и сгенерировать открытый и закрытый ключи сервера:
```wg genkey | tee private.key | wg pubkey | tee public.key```

#### Вернуться в корневую директорию WG (```/etc/wireguard```), создать файл конфигурации для WG, в моем случае ```wg0.conf```, задать порт и закрытый ключ, а остальные параметры я просто не помню, ы:
```bash
[Interface]
Address = 10.8.0.1/24
SaveConfig = true
PostUp = ufw route allow in on {название WG интерфейса} out on {основной интерфейс сервера, на который всё приходит и с которго будет уходить} comment "for {название WG интерфейса}"
PostUp = ufw allow {необходимый порт} comment "{название WG интерфейса} here"
PostUp = iptables -t nat -I POSTROUTING -o {основной интерфейс сервера} -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o {основной интерфейс сервера} -j MASQUERADE
PreDown = ufw route delete allow in on {название WG интерфейса} out on {основной интерфейс сервера}
PreDown = ufw delete allow {необходимый порт}
PreDown = iptables -t nat -D POSTROUTING -o {основной интерфейс сервера} -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o {основной интерфейс сервера} -j MASQUERADE
ListenPort = {необходимый порт}
PrivateKey = {закрытый ключ сервера}
```

Ладно, я вспомнил пояснения (и немного нашел):

```wg0``` - имя конфига

```SaveConfig = true``` - клиенты добавленные "на лету" будут записаны в файл

```Address``` - адрес сервера в сети VPN;

```ListenPort``` - порт, на котором будет ожидать подключения WireGuard;

```PrivateKey``` - приватный ключ сервера, сгенерированный ранее;

```PostUp``` - команда, которая выполняется после запуска сервера. В данном случае включается поддержка MASQUERADE для интерфейса какого там надо, а также разрешается прием пакетов на интерфейсе wg0.

```PostDown``` - выполняется после завершения работы WireGuard, в данном случае удаляет все правила, добавленные в PostUp

#### Запуск сервера:

```wg-quick up wg0```

Или через systemd:

```systemctl start wg-quick@wg0```

С помощью systemd можно (нужно) настроить автозагрузку интерфейса:

```systemctl enable wg-quick@wg0```

Ну и статус проверить:

```systemctl status wg-quick@wg0```

Или при помощи команды ```wg show```.

#### Короткое создание клиента

Полное описано в [wg_help.md](https://github.com/user-is-absinthe/rpi_scripts/blob/master/wireguard_setup/wg_help.md)
или можно воспользоваться скрпитом
[user_add.sh](https://github.com/user-is-absinthe/rpi_scripts/blob/master/wireguard_setup/user_add.sh):

1. Создать ключи:

```wg genkey | tee private.key |  wg pubkey > public.key```

2. Создать конфигурацию:

Создать файл конфигурации пира ```nano conf.conf```:

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

3. Установить утилиту для генерации QR-кодов:

```apt install qrencode -y```

4. Сгенерировать qr:

```qrencode -t ansiutf8 < conf.conf```

5. Добавить устройство в конфиг сервера:

```wg set wg0 peer {pub.key пира} allowed-ips 10.8.0.{ЦИФРА ПРИСВОЕННОГО IP}```

6. Удалить, если что:

```wg set wg0 peer {pub.key пира} remove```
