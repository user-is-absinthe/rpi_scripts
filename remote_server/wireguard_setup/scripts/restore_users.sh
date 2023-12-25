#!/bin/bash
KEYS_DIR="keys"
PUBKEY_SERVER="публичный ключ сервера"
IP_SERVER="123.456.789.123"
PORT_SERVER="порт"
DNS_SERVER="9.9.9.9"
#DNS_SERVER="8.8.8.8"
# Почему-то в некоторых местах некоторые DNS не работают...

all_config_dir="config_and_qr"
verbose=false


if ! [[ $# -gt 0 ]]
    then
        echo "Error: Missing arguments."
        echo "./restore_users.sh -i {последний октет IP} -u {username without spaces} -f {название интерфейса wg}"
        echo "Для вывода QR сразу добавить аргумент -v."
        echo "Example:"
        echo "./restore_users.sh -i 97 -u iPhone_Igor -f wg0"
        echo "          OR"
        echo "./restore_users.sh -i 97 -u iPhone_Igor -f wg0 -v"
        exit 0
fi

while getopts i:u:f:v flag
do
    case "${flag}" in
        i) ip=${OPTARG};;
        u) username=${OPTARG};;
        f) wg_interface_name=${OPTARG};;
        v) verbose=true;;
        *) echo "Error with arguments, run without it."
          exit 1
    esac
done

# проверка того, что все аргументы переданы (существуют/присвоены)
if [ -z "$ip" ] || [ -z "$username" ] || [ -z "$wg_interface_name" ]; 
    then
        echo 'Missing one or more arguments.' >&2
        exit 1
fi

# проверка того, что указанный интерфейс поднят и работает
if wg | grep -q "$wg_interface_name"
then
        echo "Interface found."
else
        echo "Interface not found."
        exit 1
fi

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
        # exit 1
        mkdir -p "$KEYS_DIR"
        echo "Info: Create dir."
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
dir_name="${wg_interface_name}_${ip}_${username}"
path_to_work_dir=$KEYS_DIR/$dir_name
mkdir -p "$path_to_work_dir"

# генерируем открытый и закрытый ключи и сохраняем в файлы
private_key=`wg genkey`
echo "$private_key" > "${path_to_work_dir}/private.key"
public_key=`echo $private_key | wg pubkey`
echo "$public_key" > "${path_to_work_dir}/public.key"

# генерируем файл конфигурации
config="[Interface]
PrivateKey = ${private_key}
Address = 10.8.0.${small_ip}/24
DNS = ${DNS_SERVER}

[Peer]
PublicKey = ${PUBKEY_SERVER}
AllowedIPs = 0.0.0.0/0
Endpoint = ${IP_SERVER}:${PORT_SERVER}"

mkdir -p "${all_config_dir}/$dir_name"

echo "$config" > "${path_to_work_dir}/config.conf"
echo "$config" > "${all_config_dir}/$dir_name/${ip}_${username}.conf"

# добавляем открытый ключ на сервер
`wg set ${wg_interface_name} peer ${public_key} allowed-ips 10.8.0.${small_ip}`

# echo "Already done!"
echo "${username} with IP 10.8.0.${small_ip}"

if [ "$verbose" = true ];
    then
        #echo "real verbose"
        echo "$config" | qrencode -t ansiutf8
#    else
#        echo "not verbose"
fi
#echo "$config" | qrencode -t ansiutf8
# cat "${path_to_work_dir}/config.conf"

echo "$config"  | qrencode -o "${all_config_dir}/$dir_name/${ip}_${username}.png"
