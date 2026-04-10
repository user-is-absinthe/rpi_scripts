#!/bin/bash

# Проверка запуска от имени root
if [[ $EUID -ne 0 ]]; then
   echo "Ошибка: Этот скрипт должен быть запущен от имени root (используйте sudo)."
   exit 1
fi

# 1. Ввод параметров пользователем
read -p "Введите название WireGuard интерфейса (по умолчанию: wg-local): " WG_IFACE
WG_IFACE=${WG_IFACE:-wg-local}

read -p "Введите подсеть сервера (по умолчанию: 10.8.0.1/24): " WG_NET
WG_NET=${WG_NET:-10.8.0.1/24}

read -p "Введите порт для прослушивания (по умолчанию: 51820): " WG_PORT
WG_PORT=${WG_PORT:-51820}

# 2. Автоматическое определение основного интерфейса
MAIN_IFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)
if [ -z "$MAIN_IFACE" ]; then
    echo "Ошибка: Не удалось автоматически определить основной сетевой интерфейс."
    read -p "Введите его вручную (например, eth0 или ens3): " MAIN_IFACE
fi
echo "Основной интерфейс определен как: $MAIN_IFACE"

# 3. Установка WireGuard
echo "[1/5] Установка пакетов..."
apt update
apt install wireguard -y

# 4. Включение проброса трафика (IP Forwarding)
echo "[2/5] Настройка проброса трафика (IP Forwarding)..."
if grep -q "^#net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
elif grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo " -> IP Forwarding уже включен."
else
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p

# 5. Создание директорий и генерация ключей сервера
echo "[3/5] Генерация ключей сервера..."
WG_DIR="/etc/wireguard"
KEY_DIR="$WG_DIR/keys/server"

mkdir -p "$KEY_DIR"
cd "$KEY_DIR"

wg genkey | tee private.key | wg pubkey > public.key
chmod 600 private.key

# Чтение ключей в переменные
PRIVATE_KEY=$(cat private.key)
PUBLIC_KEY=$(cat public.key)

# 6. Создание конфигурационного файла сервера (ТОЛЬКО IPTABLES)
echo "[4/5] Создание конфигурационного файла $WG_IFACE.conf..."
CONFIG_FILE="$WG_DIR/$WG_IFACE.conf"

cat << EOF > "$CONFIG_FILE"
[Interface]
Address = $WG_NET
SaveConfig = true
# Правила для проброса трафика между интерфейсами
PostUp = iptables -I FORWARD -i $WG_IFACE -o $MAIN_IFACE -j ACCEPT
PostUp = ip6tables -I FORWARD -i $WG_IFACE -o $MAIN_IFACE -j ACCEPT
# Правила NAT (Masquerade) для выхода в интернет
PostUp = iptables -t nat -I POSTROUTING -o $MAIN_IFACE -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o $MAIN_IFACE -j MASQUERADE
# Удаление правил при остановке WireGuard
PreDown = iptables -D FORWARD -i $WG_IFACE -o $MAIN_IFACE -j ACCEPT
PreDown = ip6tables -D FORWARD -i $WG_IFACE -o $MAIN_IFACE -j ACCEPT
PreDown = iptables -t nat -D POSTROUTING -o $MAIN_IFACE -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o $MAIN_IFACE -j MASQUERADE

ListenPort = $WG_PORT
PrivateKey = $PRIVATE_KEY
EOF

chmod 600 "$CONFIG_FILE"

# 7. Запуск и добавление в автозагрузку
echo "[5/5] Запуск WireGuard и добавление в автозагрузку..."
systemctl enable wg-quick@$WG_IFACE
systemctl start wg-quick@$WG_IFACE

# Проверка статуса
sleep 1
SERVICE_STATUS=$(systemctl is-active wg-quick@$WG_IFACE)

# 8. Вывод итоговой информации
clear
echo "=================================================="
echo "          НАСТРОЙКА СЕРВЕРА ЗАВЕРШЕНА             "
echo "=================================================="
echo "Интерфейс WG: $WG_IFACE"
echo "Подсеть:      $WG_NET"
echo "Порт WG:      $WG_PORT"
echo "Статус:       $SERVICE_STATUS"
echo "--------------------------------------------------"
echo "Публичный ключ сервера (нужен для клиентов):"
echo "$PUBLIC_KEY"
echo "=================================================="
echo ""
echo "ВНИМАНИЕ! Порт WireGuard НЕ открыт в UFW автоматически."
echo "Скопируйте и выполните команду ниже, чтобы открыть его:"
echo ""
echo "--------------------------------------------------"
echo -e "\e[1;32mufw allow $WG_PORT/udp comment 'WireGuard $WG_IFACE'\e[0m"
echo "--------------------------------------------------"
echo ""
echo "После выполнения команды проверьте список правил:"
echo "  ufw status"
echo ""
