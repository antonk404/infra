#!/bin/bash

AWG0_CONF="/etc/amnezia/amneziawg/awg0.conf"

sysctl -w net.ipv4.ip_forward=0
iptables -D FORWARD -i awg0 -o eth0 -j ACCEPT --wait 10
iptables -D FORWARD -i awg0 -o awg1 -j ACCEPT --wait 10
iptables -D FORWARD -i awg0 -o awg2 -j ACCEPT --wait 10
iptables -D FORWARD -i awg1 -o awg0 -j ACCEPT --wait 10
iptables -D FORWARD -i awg2 -o awg0 -j ACCEPT --wait 10
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE --wait 10
iptables -D FORWARD -i eth0 -o awg0 -j ACCEPT
iptables -D FORWARD -i awg0 -o awg0 -j ACCEPT

ip rule del from 10.2.0.0/24 prio 50 lookup wgshared 2>/dev/null || true

while IFS= read -r N; do
    ip rule del from "10.2.0.$N" prio 100 lookup "$((200 + N))" 2>/dev/null || true
    ip route flush table "$((200 + N))" 2>/dev/null || true
done < <(grep -oP 'AllowedIPs = 10\.2\.0\.\K\d+(?=/32)' "$AWG0_CONF")

ip route flush table wgshared 2>/dev/null || true
