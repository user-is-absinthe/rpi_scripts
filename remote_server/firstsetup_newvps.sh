#!/bin/bash

# ===== НАСТРОЙКА ПЕРЕМЕННЫХ =====
USERNAME="user"                  # Имя нового пользователя
NEW_SSH_PORT="22540"             # Новый порт SSH
PUBKEYS="ssh-rsa AAAAB3... user1@host
ssh-rsa AAAAB3... user2@host
ssh-ed25519 AAAAC3... user3@host"
# ================================

# Смена пароля root
echo "Смена пароля root:"
passwd

# Создание пользователя
adduser --gecos "" $USERNAME
usermod -aG sudo $USERNAME

# Проверка sudo-доступа
echo "Проверка доступа:"
su - $USERNAME -c "sudo whoami"

# Настройка SSH-ключей
# Настройка SSH-ключей
mkdir -p /home/$USERNAME/.ssh
echo "$PUBKEYS" > /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# Резервная копия конфига SSH
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old

# Настройка SSH
cat >> /etc/ssh/sshd_config << EOF
# Custom settings
Port $NEW_SSH_PORT
LoginGraceTime 30
PasswordAuthentication no
PermitRootLogin no
EOF

# Переход с socket на daemon (для новых Ubuntu)
systemctl stop ssh.socket 2>/dev/null
systemctl disable ssh.socket 2>/dev/null
systemctl enable ssh.service
systemctl start ssh.service

# Установка утилит
apt update && apt install -y net-tools ufw

# Настройка firewall
ufw allow $NEW_SSH_PORT comment "SSH custom port"
ufw enable

echo "Настройка завершена!"
echo "Количество добавленных SSH-ключей: ${#PUBKEYS[@]}"
echo "Не забудьте проверить подключение по новому порту: ssh $USERNAME@server -p $NEW_SSH_PORT"
