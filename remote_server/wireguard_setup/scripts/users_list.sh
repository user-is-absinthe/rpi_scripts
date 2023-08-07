#!/usr/bin/env bash
# да, тут нет защиты от дурака и проверки наличия лишних файлов/папок в ключевой директории*
# потому что потому, вот почему
# команда с любым аргументом покажет закрытые ключи, но этот функционал особо не нужен
# просто мне жаль удалять
#
# * хотя сейчас одну проверку я всё же сделаю...

KEYS_DIR="keys"
CONFIG_FILE_NAME="config"

users_list=("username")
public_keys=("public_key")
private_keys=("private_key")

to_replace="${KEYS_DIR}/"
# это тут мы просто перебираем всё в папочке
for f_name in "${KEYS_DIR}"/*
do
    # а вот тут уже берем название, лол
    short_f_name="${f_name/$to_replace/""}"

    # а вот это мы тут сделаем ту самую проверку * - если файл или папака начинаются не с цифры, то пропускаем
    if ! [[ $short_f_name =~ ^[0-9]* ]]
    then
        continue
    fi

    # пропускаем сервер в табличке
    if [[ $f_name == "${KEYS_DIR}/001"* ]]
    then
        continue
    fi

    # и только после всех проверок начинаем добавлять названия и всё такое прочее
    users_list[${#users_list[@]}]="${short_f_name}"

    # берем открытый ключ
    public_keys[${#public_keys[@]}]=$(<"${f_name}/public.key")

    # а вот тут попытаемся открыть файл и дернуть закрытые ключи
    while read -r line;
    do
        if [[ $line == "PrivateKey = "* ]]
        then
            private_key="${line/"PrivateKey = "/""}"
            private_keys[${#private_keys[@]}]="${private_key}"
        fi
    done < "${f_name}"/"${CONFIG_FILE_NAME}".conf
done

#echo "finally"

# показываем их всех
index=0
for value in "${users_list[@]}"
do
    if [ -z "$1" ]
    then
        echo "${index}. ${value}    ---   ${public_keys[$index]}"
    else
        echo "${index}. ${value}    ---   ${public_keys[$index]}   ---   ${private_keys[$index]}"
    fi
    index=$((index + 1))
done
