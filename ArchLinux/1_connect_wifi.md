# Подключение в Arch Wi-Fi

Для начала придется грузиться с клавиатурой и монитором, так как способа
стартовать "без головы" я не нашел.

# Создание конфигурациионного файла.

## Способ 1. Опробовано.

### Создание заготовки конфигурациионного файла

```bash
nano /etc/wpa_supplicant/wpa_supplicant.conf
```

В него добавить:

```bash
ctrl_interface=/run/wpa_supplicant
update_config=1
```

### Старт wpa_supplicant

```bash
wpa_supplicant -B -i interface -c /etc/wpa_supplicant/wpa_supplicant.conf
```

### Затем:

```bash
wpa_cli
```

### Где в интерактивном режиме запустить сканирование

```bash
> scan
    OK
    <3>CTRL-EVENT-SCAN-RESULTS
> scan_results
    bssid / frequency / signal level / flags / ssid
    00:00:00:00:00:00 2462 -49 [WPA2-PSK-CCMP][ESS] MYSSID
    11:11:11:11:11:11 2437 -64 [WPA2-PSK-CCMP][ESS] ANOTHERSSID
```

### После чего выполнить подключение (?)

```bash
> add_network
    0
> set_network 0 ssid "MYSSID"
> set_network 0 psk "passphrase"
> enable_network 0
    <2>CTRL-EVENT-CONNECTED - Connection to 00:00:00:00:00:00 completed (reauth) [id=0 id_str=]
```

### Сохрнить конфиг и выйти

```bash
> save_config
    OK
> quit
```

## Способ 2. Непроверено.

### Создание конфиг-файла и работа с ним.

```bash
wpa_passphrase MYSSID passphrase > /etc/wpa_supplicant/wpa_supplicant.conf
```

Должен получиться файл следующего содержания:

```bash
network={
    ssid="MYSSID"
    #psk="passphrase"
    psk=59e0d07fa4c7741797a4e394f38a5c321e3bed51d54ad5fcbd3f84bc7415d73d
}
```

# Подключение

### Подключение через wpa_supplicant

```bash
wpa_supplicant -B -i {interface} -c /etc/wpa_supplicant/wpa_supplicant.conf
```

### Получение IP (без него не работает)

```bash
dhcpcd {interface}
```

---

Вся информация взята с официальной [вики](https://wiki.archlinux.org/index.php/Wpa_supplicant#Connecting_with_wpa_cli).