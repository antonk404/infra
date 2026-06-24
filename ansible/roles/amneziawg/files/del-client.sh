#!/bin/bash
set -e

HUB_STATE="/etc/amnezia/amneziawg/user-hubs"

NAME="$1"
CONFIG_FILE="$2"
CLIENTS_DIR="${3:-/etc/amnezia/amneziawg/clients}"

CLIENT_CONF="$CLIENTS_DIR/$NAME.conf"

if [ ! -f "$CLIENT_CONF" ]; then
    echo "Клиент '$NAME' не найден"
    exit 1
fi

# Определяем IP клиента до удаления из конфига
CLIENT_IP=$(awk -v name="$NAME" '
    /^\[Peer\]/ { cur_name=""; cur_ip=""; next }
    /^# /       { cur_name=substr($0, 3) }
    /^AllowedIPs/ { match($0, /10\.2\.0\.[0-9]+/, a); cur_ip=a[0] }
    cur_name && cur_ip {
        if (cur_name == name) { print cur_ip; exit }
        cur_name=""; cur_ip=""
    }
' "$CONFIG_FILE")

# Удаляем [Peer] блок из серверного конфига
python3 - "$NAME" "$CONFIG_FILE" << 'PYEOF'
import sys, re

name = sys.argv[1]
config_file = sys.argv[2]

with open(config_file, 'r') as f:
    content = f.read()

sections = re.split(r'\n{2,}', content)
filtered = [s for s in sections if not (
    s.lstrip().startswith('[Peer]') and
    any(line.strip() == f'# {name}' for line in s.splitlines())
)]

result = '\n\n'.join(filtered)
if not result.endswith('\n'):
    result += '\n'

with open(config_file, 'w') as f:
    f.write(result)
PYEOF

rm -f "$CLIENT_CONF"

# Чистим ip rule и таблицу маршрутизации до рестарта
# (postdown их не тронет — пир уже убран из конфига)
if [ -n "$CLIENT_IP" ]; then
    OCTET="${CLIENT_IP##*.}"
    TABLE=$((200 + OCTET))
    ip rule del from "$CLIENT_IP" prio 100 lookup "$TABLE" 2>/dev/null || true
    ip route flush table "$TABLE" 2>/dev/null || true
fi

# Удаляем из состояния hub
if [ -n "$CLIENT_IP" ]; then
    sed -i "/^${CLIENT_IP} /d" "$HUB_STATE" 2>/dev/null || true
fi

systemctl restart awg-quick@awg0

echo "Клиент '$NAME' удалён"
