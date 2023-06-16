#!/bin/bash
KEYS_DIR="keys"
WG_INTERFACE_NAME="wg0"
PUBKEY_SERVER="super_key="
IP_SERVER="123.234.123.234"
PORT_SERVER="123"

all_config_dir="config_and_qr"

if ! [[ $# -gt 0 ]]
    then
        echo "Error: Missing arguments."
        echo "./restore_users.sh -i {последний октет IP} -u {username without spaces}"
        echo "Example:"
        echo "./restore_users.sh -i 97 -u iPhone_Igor"
        exit 0
fi

while getopts i:u: flag
do
    case "${flag}" in
        i) ip=${OPTARG};;
        u) username=${OPTARG};;
        *) echo "Error with arguments, run without it."
          exit 1
    esac
done

# проверка IP на число вообще
re='^[0-9]+$'
if ! [[ $ip =~ $re ]]
    then
        echo "Error: IP is not a number."
        exit 1
fi

# проверка IP на принадлежность диапазону 2-254
if (($ip <= 1)) || (($ip >= 255))
    then
        echo "Error: IP from not valid diapasone."
        exit 1
fi

# echo "10.8.0.${ip}/24 --- ${username} will be added."

# дополнение ведущими нулями
small_ip=$ip
while ((${#ip} < 3))
do
    ip="0${ip}"
done

# echo "${ip}"

# проверка наличия директории с папочкой с ключами
if ! [ -d "$KEYS_DIR" ]
    then
        echo "Error: Cannot find keys directory."
        exit 1
fi

# проверка занятости данного IP
for f in "$KEYS_DIR"/*
do
    # echo "${f}"
    # f="${f/$KEYS_DIR/""}"
    # echo "${f}"
    # echo "$KEYS_DIR/$ip"
    if [[ $f == $KEYS_DIR/$ip* ]]
        then
            echo "Error: This IP is already taken."
            exit 1
        # else
        #     echo "not error"
    fi
    # echo ""
done

# создаем папочку с IP и именем
dir_name="${ip}_${username}"
path_to_work_dir=$KEYS_DIR/$dir_name
mkdir "$path_to_work_dir"

# генерируем открытый и закрытый ключи и сохраняем в файлы
private_key=`wg genkey`
echo "$private_key" > "${path_to_work_dir}/private.key"
public_key=`echo $private_key | wg pubkey`
echo "$public_key" > "${path_to_work_dir}/public.key"

# генерируем файл конфигурации
config="[Interface]
PrivateKey = ${private_key}
Address = 10.8.0.${small_ip}/24
DNS = 8.8.8.8

[Peer]
PublicKey = ${PUBKEY_SERVER}
AllowedIPs = 0.0.0.0/0
Endpoint = ${IP_SERVER}:${PORT_SERVER}"
echo "$config" > "${path_to_work_dir}/config.conf"
echo "$config" > "${all_config_dir}/${ip}_${username}.conf"

# добавляем открытый ключ на сервер
`wg set ${WG_INTERFACE_NAME} peer ${public_key} allowed-ips 10.8.0.${small_ip}`

# echo "Already done!"
echo "${username} with IP 10.8.0.${small_ip}"
#echo "$config" | qrencode -t ansiutf8
# cat "${path_to_work_dir}/config.conf"
echo "$config"  | qrencode -o "${all_config_dir}/${ip}_${username}.png"
