# Установка SaMBa-сервера на вашу малину

### 1. Обновить все зависимсти

```bash
sudo apt-get update
sudo apt-get upgrade
```

### 2. Установить пакеты для работы с Samba:

```bash
sudo apt-get install samba samba-common-bin
```

### 3. Для внешних дисков - создать точки монтирования:

```bash
sudo mkdir /mnt/1_tb
sudo mkdir /mnt/2_tb
```

### 4. Посмотреть пути дисков в системе 

при помощи ```sudo fdisk -l```, затем создать запись в ```/etc/fstab```
для автоматического монтирования при включении:
```bash
/dev/sda1   /mnt/1_tb    ntfs-3g rw,auto,user,fmask=0111,dmask=0000,noatime,nodiratime   0   0
/dev/sdb1   /mnt/2_tb    ntfs-3g rw,auto,user,fmask=0111,dmask=0000,noatime,nodiratime   0   0
```

```noatime``` и ```nodiratime``` - некоторые дополнительные параметры
для оптимизации. Можно их удалить.

Для FAT32 заменить ```ntfs-3g``` на
```vfat```.

### 5. Настроить файл конфигурации:

```bash
sudo nano /etc/samba/smb.conf
```

```bash
[one_tb]
path = /mnt/1_tb
writeable=Yes
create mask=0777
directory mask=0777
public=no

[two_tb]
path = /mnt/2_tb
writeable=Yes
create mask=0777
directory mask=0777
public=no
```

С параметрами:


```[one_tb]``` – определяет название общиего ресурса, текст в скобках -
это точка, в которой будет получен доступ. Например, эта будет по
адресу: ```//{IP-address PI}/one_tb```

```path``` – Точка монтирования папки.

```writeable``` – Доступна ли для записи.

```create mask``` и ```directory mask``` – Права доступа для внутрених
папок. 0777 - чтение, запись и выполнение.

```public``` – Авторизованный доступ.

### 6. Создать полльзователя 

```netuser```

Примечание: для Samba 3 необходимо сначала добавить пользователя в
систему:

```adduser netuser``` 

и задать ему пароль, после чего добавить
пользователя в Samba 

```sudo smbpasswd -a netuser``` 

и задать ему пароль (можно отличный от системного).

### 7. Перезагрузить Samba 

```sudo systemctl restart smbd```.

### 8. В удаленной системе подключить ситевой диск 

используя путь ИЗ НАЗВАНИЯ SMB.CONF - ```\\192.168.1.243\one_tb```!!!

*(Несколько часов страданий и сколько-то тысяч нервных клеток.)*

### 9. Вы восхитительны.   
