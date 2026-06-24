#!/bin/bash
CONFIG_FILE="$1"
HUB_STATE="/etc/amnezia/amneziawg/user-hubs"

[[ "$CONFIG_FILE" != *.conf ]] && CONFIG_FILE="${CONFIG_FILE}.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Конфиг не найден: $CONFIG_FILE"
    exit 1
fi

# Читаем состояние hub: IP -> hub
declare -A HUB_MAP
if [ -f "$HUB_STATE" ]; then
    while IFS=' ' read -r IP HUB; do
        [[ -z "$IP" || "$IP" =~ ^# ]] && continue
        HUB_MAP["$IP"]="$HUB"
    done < "$HUB_STATE"
fi

# Парсим конфиг: имя + IP, добавляем hub
awk '/^\[Peer\]/{p=1; name=""; ip=""; next}
     p && /^# /{ name=substr($0,3) }
     p && /^AllowedIPs/{ match($0, /10\.2\.0\.[0-9]+/, a); ip=a[0] }
     p && name && ip { print name "\t" ip; name=""; ip=""; p=0 }
     p && /^\[/{ p=0 }' "$CONFIG_FILE" \
| while IFS=$'\t' read -r NAME IP; do
    HUB="${HUB_MAP[$IP]:-?}"
    printf "%-20s %-15s %s\n" "$NAME" "$IP" "$HUB"
done
