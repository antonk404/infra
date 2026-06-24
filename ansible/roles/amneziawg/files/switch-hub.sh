#!/bin/bash
set -e

AWG0_CONF="/etc/amnezia/amneziawg/awg0.conf"
HUB_STATE="/etc/amnezia/amneziawg/user-hubs"

# Returns IP for a given username by parsing awg0.conf
get_ip_by_name() {
    local target="$1"
    awk -v name="$target" '
        /^\[Peer\]/ { cur_name=""; cur_ip=""; next }
        /^# /       { cur_name=substr($0, 3) }
        /^AllowedIPs/ { match($0, /10\.2\.0\.[0-9]+/, a); cur_ip=a[0] }
        cur_name && cur_ip {
            if (cur_name == name) { print cur_ip; exit }
            cur_name=""; cur_ip=""
        }
    ' "$AWG0_CONF"
}

# Returns all peer last octets from awg0.conf
get_all_octets() {
    grep -oP 'AllowedIPs = 10\.2\.0\.\K\d+(?=/32)' "$AWG0_CONF"
}

switch_user() {
    local IP="$1" HUB="$2"
    local OCTET="${IP##*.}"
    local TABLE=$((200 + OCTET))
    local DEV GW

    case "$HUB" in
        us) DEV=awg2 ;;
        de) DEV=awg1 ;;
        ru) DEV=eth0; GW=81.85.78.1 ;;
        *) echo "Unknown hub: $HUB (use de, us, or ru)" >&2; exit 1 ;;
    esac

    if [ -n "$GW" ]; then
        ip route replace default via "$GW" dev "$DEV" table "$TABLE"
    else
        ip route replace default dev "$DEV" table "$TABLE"
    fi

    sed -i "/^$IP /d" "$HUB_STATE" 2>/dev/null || true
    echo "$IP $HUB" >> "$HUB_STATE"
    echo "$IP → $HUB ($DEV)"
}

restore_all() {
    if [ ! -f "$HUB_STATE" ]; then
        while IFS= read -r N; do
            ip route replace default dev awg1 table "$((200 + N))"
            echo "10.2.0.$N de" >> "$HUB_STATE"
        done < <(get_all_octets)
        return
    fi

    while IFS=' ' read -r IP HUB; do
        [[ -z "$IP" || "$IP" =~ ^# ]] && continue
        switch_user "$IP" "$HUB"
    done < "$HUB_STATE"
}

# --- main ---
if [ $# -eq 0 ]; then
    restore_all
    exit 0
fi

TARGET="$1"
HUB="$2"

if [ -z "$HUB" ]; then
    echo "Usage: switch-hub <username|10.2.0.N> <de|us|ru>" >&2
    exit 1
fi

if [[ "$TARGET" =~ ^10\.2\.0\. ]]; then
    switch_user "$TARGET" "$HUB"
else
    IP=$(get_ip_by_name "$TARGET")
    if [ -z "$IP" ]; then
        echo "Unknown user: $TARGET" >&2
        exit 1
    fi
    switch_user "$IP" "$HUB"
fi
