#!/bin/bash
set -euo pipefail

# ===== НАСТРОЙКА ПЕРЕМЕННЫХ =====
USERNAME="user"                  # Имя нового пользователя
NEW_SSH_PORT="22540"             # Новый порт SSH
PUBKEYS="ssh-rsa AAAAB3... user1@host
ssh-rsa AAAAB3... user2@host
ssh-ed25519 AAAAC3... user3@host"
# ================================

echo "Подготовлено при помощи моделей семейства Qwen"

echo "🚀 Начало настройки безопасности сервера"
echo "======================================="

# Проверка запуска от root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Ошибка: запускайте скрипт от имени root"
    exit 1
fi

# Проверка занятости порта
if ss -tulpn 2>/dev/null | grep -q ":${NEW_SSH_PORT} "; then
    echo "❌ Ошибка: порт $NEW_SSH_PORT уже занят!"
    exit 1
fi

# Смена пароля root
echo -e "\n🔐 Смена пароля root:"
passwd

# Создание пользователя (если не существует)
if ! id "$USERNAME" &>/dev/null; then
    echo -e "\n👤 Создание пользователя $USERNAME..."
    adduser --gecos "" --disabled-password "$USERNAME"
else
    echo "⚠️  Пользователь $USERNAME уже существует"
fi

# Добавление в группу sudo
usermod -aG sudo "$USERNAME"

# Настройка sudo без пароля (через файл в sudoers.d)
echo -e "\n🛡️  Настройка sudo без пароля для $USERNAME..."
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME-nopasswd"
chmod 440 "/etc/sudoers.d/$USERNAME-nopasswd"
echo "✅ Проверка: $(su - "$USERNAME" -c 'sudo -n whoami' 2>/dev/null || echo 'не удалось')"

# Настройка SSH-ключей
echo -e "\n🔑 Настройка SSH-ключей..."
mkdir -p "/home/$USERNAME/.ssh"
echo "$PUBKEYS" | grep -v '^\s*$' > "/home/$USERNAME/.ssh/authorized_keys"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
chmod 700 "/home/$USERNAME/.ssh"
chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
KEY_COUNT=$(echo "$PUBKEYS" | grep -c '^ssh-' || echo "0")
echo "✅ Добавлено ключей: $KEY_COUNT"

# Резервная копия конфига SSH
echo -e "\n💾 Создание резервной копии SSH конфигурации..."
cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%Y%m%d_%H%M%S)"

# Безопасное комментирование старых параметров
echo "🧹 Очистка старых настроек из sshd_config..."
for key in Port LoginGraceTime PasswordAuthentication PermitRootLogin; do
    sed -i -E "/^[[:space:]]*${key}[[:space:]]/s/^/# /" /etc/ssh/sshd_config
done

# Добавление новых параметров
echo -e "\n⚙️  Применение новых настроек SSH..."
cat << EOF >> /etc/ssh/sshd_config

# Custom security settings (applied $(date '+%Y-%m-%d %H:%M:%S'))
Port $NEW_SSH_PORT
LoginGraceTime 30
PasswordAuthentication no
PermitRootLogin no
AllowUsers $USERNAME
EOF

# Проверка синтаксиса конфигурации
echo "🔍 Проверка синтаксиса SSH конфигурации..."
if ! sshd -t; then
    echo "❌ Ошибка в конфигурации SSH! Скрипт прерван."
    exit 1
fi

# Определение имени службы SSH (ssh vs sshd)
SSH_SERVICE="ssh"
if ! systemctl is-active --quiet "$SSH_SERVICE" 2>/dev/null; then
    if systemctl is-active --quiet "sshd" 2>/dev/null; then
        SSH_SERVICE="sshd"
    fi
fi

# Переход с socket на daemon (для новых Ubuntu)
echo "🔄 Переключение с socket на service..."
systemctl stop ssh.socket 2>/dev/null || true
systemctl disable ssh.socket 2>/dev/null || true
systemctl enable "${SSH_SERVICE}.service" --now

# Перезагрузка SSH для применения настроек
echo "🔁 Перезагрузка SSH сервиса..."
systemctl reload "$SSH_SERVICE" || systemctl restart "$SSH_SERVICE"

# Проверка, что новый порт слушается
sleep 2
if ! ss -tulpn 2>/dev/null | grep -q ":${NEW_SSH_PORT} "; then
    echo "❌ SSH не слушает порт $NEW_SSH_PORT! Проверьте конфигурацию."
    exit 1
fi

# Установка и настройка фаервола
echo -e "\n🔥 Установка и настройка UFW..."
apt update -qq && apt install -y -qq net-tools ufw

ufw allow "$NEW_SSH_PORT"/tcp comment "SSH custom port" >/dev/null 2>&1
ufw --force enable >/dev/null 2>&1
ufw status verbose | grep -E "(Status|${NEW_SSH_PORT})"

# Финальное сообщение
echo -e "\n======================================="
echo "✅ Настройка завершена успешно!"
echo -e "\n📌 Важная информация:"
echo "   • Пользователь: $USERNAME"
echo "   • SSH порт: $NEW_SSH_PORT"
echo "   • Sudo без пароля: ✅ включено"
echo "   • Парольная аутентификация: ❌ отключена"
echo "   • Root-доступ по SSH: ❌ запрещён"
echo -e "\n🔌 Подключайтесь командой:"
echo "   ssh -p $NEW_SSH_PORT $USERNAME@<ваш_сервер>"
echo -e "\n⚠️  Старый порт 22 будет недоступен после перезагрузки"
echo "======================================="
