#!/bin/bash
# ============ НАСТРОЙКИ СЕРВЕРА ============
SERVER_CONF="/etc/amnezia/amneziawg/awg0.conf"
CLIENTS_DIR="/etc/amnezia/amneziawg/clients"
SERVER_PUBLIC_KEY=$(grep PrivateKey "$SERVER_CONF" | awk '{print $3}' | awg pubkey)
SERVER_IP="81.85.78.139"
SERVER_PORT="51820"
VPN_SUBNET="10.2.0"

JC=4
JMIN=40
JMAX=70
S1=30
S2=40
H1=1234567891
H2=1234567892
H3=1234567893
H4=1234567894
# ===========================================

CLIENT_NAME=$1
HUB=${2:-de}

if [ -z "$CLIENT_NAME" ]; then
    echo "Использование: $0 <имя_клиента> [de|us|ru]"
    exit 1
fi

case "$HUB" in
    de|us|ru) ;;
    *) echo "Неизвестный hub: $HUB (допустимые: de, us, ru)" >&2; exit 1 ;;
esac

mkdir -p "$CLIENTS_DIR"

if [ -f "$CLIENTS_DIR/${CLIENT_NAME}.conf" ]; then
    echo "Клиент '$CLIENT_NAME' уже существует!"
    exit 1
fi

# Следующий свободный IP
LAST_IP=$(grep -oP "(?<=AllowedIPs = ${VPN_SUBNET//./\\.}\.)\d+(?=/32)" "$SERVER_CONF" | sort -n | tail -1)
NEXT_IP=${LAST_IP:-1}
NEXT_IP=$((NEXT_IP + 1))

if [ "$NEXT_IP" -gt 254 ]; then
    echo "Ошибка: подсеть заполнена!"
    exit 1
fi

CLIENT_IP="${VPN_SUBNET}.${NEXT_IP}"

# Генерируем ключи
CLIENT_PRIVATE_KEY=$(awg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | awg pubkey)

# Добавляем пира в серверный конфиг
printf '\n[Peer]\n# %s\nPublicKey = %s\nAllowedIPs = %s/32\n' \
    "$CLIENT_NAME" "$CLIENT_PUBLIC_KEY" "${CLIENT_IP}" >> "$SERVER_CONF"

# Создаём конфиг клиента
cat > "$CLIENTS_DIR/${CLIENT_NAME}.conf" << CONF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = ${CLIENT_IP}/24
DNS = 30.0.0.2
Jc = $JC
Jmin = $JMIN
Jmax = $JMAX
S1 = $S1
S2 = $S2
H1 = $H1
H2 = $H2
H3 = $H3
H4 = $H4

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = ${SERVER_IP}:${SERVER_PORT}
PersistentKeepalive = 25
CONF

systemctl reload awg-quick@awg0

# Подключаем per-user routing table (не поднимается в postup для новых клиентов)
ip rule add from "$CLIENT_IP" prio 100 lookup "$((200 + NEXT_IP))" 2>/dev/null || true

# Назначаем hub
/etc/amnezia/amneziawg/switch-hub.sh "$CLIENT_IP" "$HUB"

cat "$CLIENTS_DIR/${CLIENT_NAME}.conf"
