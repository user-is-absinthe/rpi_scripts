# Делать активное охлаждение с управлением через GPIO можно, но...

Инструкция актуальна для Debian 12 (bookworm).

1. [Включить поддержу GPIO.](https://blog.tataranovich.com/2021/08/gpio-raspberry-pi-4-debian-bullseye.html)
1.1. Дописать в ядро параметр:
```bash
echo 'iomem=relaxed' | tee /etc/default/raspi-extra-cmdline
```

1.2. Применить:
```bash
update-initramfs -u -k all
```

1.3. Проверить:
```bash
cat /boot/firmware/cmdline.txt
```

1.4. Ожидаемый вывод:
```bash
console=tty0 console=ttyS1,115200 root=/dev/sda2 rw fsck.repair=yes net.ifnames=0  rootwait iomem=relaxed
```

1.5. Перезагрузиться.

2. Изменить способ получения температуры: не через ```vcgencmd```, а через [просмотр системного файла](https://www.cyberciti.biz/faq/linux-find-out-raspberry-pi-gpu-and-arm-cpu-temperature-command/): ```cat /sys/class/thermal/thermal_zone0/temp```.
2.1. Переписать строки + помнить о том, что для получения градусов - делим на тысячу:
```python
temp = os.popen("cat /sys/class/thermal/thermal_zone0/temp").readline()
temp = float(temp) / 1000
```

3. Проверка.
3.1. Проверить [стресс-тестом](https://ph0en1x.net/102-linux-cpu-stress-test-load-cores-tools.html):
```bash
dd if=/dev/urandom | bzip2 -9 > /dev/null
```

4. Вы восхитительны, а готовый файл лежит рядом. Ссылку на него возможно прилеплю позже.

5. Не забыть воткнуть в автозагрузку.
