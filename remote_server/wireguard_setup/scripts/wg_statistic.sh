#!/usr/bin/env bash
KEYS_DIR="keys"
CONFIG_FILE_NAME="conf"
COLOR_NAME='\033[0;33m'
NOCOLOR='\033[0m'

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

# получили информацию от сервера
wg_stats=$(wg show wg0)
# делаем новый список, куда сохраним всю информацию
# new_list=()
while read -r line;
do
	if [[ $line == "peer: "* ]]
	then
		open_key="${line/peer: /""}"
		# echo "${open_key}"
		for i in "${!public_keys[@]}";
		do
			if [[ "${public_keys[$i]}" = "${open_key}" ]];
			then
				# echo "${i}";
				# echo "${users_list[${i}]}"
				echo -e "${line/peer: /"${COLOR_NAME}${users_list[${i}]}${NOCOLOR}: \n"}"
			fi
		done
	else
		echo "${line}"
	fi
done <<< "${wg_stats}"
