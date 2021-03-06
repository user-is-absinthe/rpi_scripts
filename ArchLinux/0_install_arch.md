# Установка arch-linux на Raspberry Pi

## Загрузиться в linux.

### Определение носителя.

Подключить флешку, проверить путь до неё при помощи.

```bash
lsblk
```

Монтировать флешку на донном этапе нет необходимости.

### Разметка диска.

```bash
fdisk /dev/{disk name}
```

В консоли fdisk вводим следующее, по порядку:
1. "o" - Очистка всех разделов.
2. "p" - Список разделов, на карте не должно быть разделов.
3. "n" – Новый раздел, затем "p" для установки его как основного
раздела, первый сектор будет по умолчанию 2048 жмем Enter, для
последнего сектора добавляем +100M и Enter.
4. "t" - затем "c", чтобы установить для первого раздела тип файловой
   системы - W95 FAT32 (LBA).
5. "n" – потом "p", создаем второй раздел, размеры первичного и
   последнего сектора оставляем по умолчанию, просто жмем Enter.
6. "w" – Сохраняем таблицу разделов на диске.

### Проверка разделов.

```bash
lsblk
```

### Подготовка к установке ОС.

Появились {disk name}1 и {disk name}2 - дальше работаем с ними. Но перед
этим создать две папки: "boot" и "root".

```bash
mkdir root
mkdir boot
```

### Загрузка  образа.

```bash
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
```

### Создание и работа с загрузочным разделом.

```bash
mkfs.vfat /dev/{disk name}1
mount /dev/{disk name}1 boot
```

### Создание и работа с основным разделом ОС.

```bash
mkfs.ext4 /dev/{disk name}2
mount /dev/{disk name}2 root
```

### Распаковка дистрибутива в "root".

```bash
tar zxvf ArchLinuxARM-rpi-3-latest.tar.gz –C root
```

### Синхронизация данных в памяти и на диске.

```bash
sync
```

### Перенос "boot" из "root".

```bash
mv root/boot/* boot
```

### Повторная синхронизация, отмонтирование разделов.

```bash
sync
umount root
umount boot
```

### Готово. Вставляем в малину и грузимся.

---

Основано на первой части
[этого](https://codeby.net/threads/ustanovka-blackarch-linux-na-raspberry-pi3.63634/)
материала.