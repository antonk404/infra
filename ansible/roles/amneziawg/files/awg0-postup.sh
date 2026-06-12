#!/bin/bash
set -e

AWG0_CONF="/etc/amnezia/amneziawg/awg0.conf"

# Forwarding and iptables
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -i awg0 -o eth0 -j ACCEPT --wait 10
iptables -A FORWARD -i awg0 -o awg1 -j ACCEPT --wait 10
iptables -A FORWARD -i awg0 -o awg2 -j ACCEPT --wait 10
iptables -A FORWARD -i awg1 -o awg0 -j ACCEPT --wait 10
iptables -A FORWARD -i awg2 -o awg0 -j ACCEPT --wait 10
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE --wait 10
iptables -A FORWARD -i eth0 -o awg0 -j ACCEPT
iptables -A FORWARD -i awg0 -o awg0 -j ACCEPT

# VPN client subnet reachability
ip route add 10.2.0.0/24 dev awg0 table wgshared

# Russian routes → local ISP gateway
ip route add 213.59.0.0/16      via 81.85.78.1 dev eth0 table wgshared
ip route add 82.179.190.60      via 81.85.78.1 dev eth0 table wgshared
ip route add 109.238.90.239     via 81.85.78.1 dev eth0 table wgshared
ip route add 178.248.233.148    via 81.85.78.1 dev eth0 table wgshared
ip route add 194.190.0.50       via 81.85.78.1 dev eth0 table wgshared
ip route add 212.193.153.0/24   via 81.85.78.1 dev eth0 table wgshared
ip route add 212.193.157.0/24   via 81.85.78.1 dev eth0 table wgshared
ip route add 212.193.152.0/24   via 81.85.78.1 dev eth0 table wgshared
ip route add 87.250.0.0/16      via 81.85.78.1 dev eth0 table wgshared
ip route add 46.235.0.0/16      via 81.85.78.1 dev eth0 table wgshared
ip route add 91.221.0.0/16      via 81.85.78.1 dev eth0 table wgshared
# Ya
ip route add 5.45.192.0/19      via 81.85.78.1 dev eth0 table wgshared
ip route add 5.255.192.0/18     via 81.85.78.1 dev eth0 table wgshared
ip route add 37.9.109.0/24      via 81.85.78.1 dev eth0 table wgshared
ip route add 37.140.128.0/18    via 81.85.78.1 dev eth0 table wgshared
ip route add 77.88.0.0/18       via 81.85.78.1 dev eth0 table wgshared
ip route add 84.201.128.0/18    via 81.85.78.1 dev eth0 table wgshared
ip route add 87.250.224.0/19    via 81.85.78.1 dev eth0 table wgshared
ip route add 93.158.136.48/28   via 81.85.78.1 dev eth0 table wgshared
ip route add 95.108.130.0/23    via 81.85.78.1 dev eth0 table wgshared
ip route add 95.108.192.0/18    via 81.85.78.1 dev eth0 table wgshared
ip route add 141.8.132.0/24     via 81.85.78.1 dev eth0 table wgshared
ip route add 178.154.128.0/17   via 81.85.78.1 dev eth0 table wgshared
ip route add 213.180.192.0/19   via 81.85.78.1 dev eth0 table wgshared
ip route add 213.180.223.192/26 via 81.85.78.1 dev eth0 table wgshared
ip route add 51.250.56.0/24     via 81.85.78.1 dev eth0 table wgshared
ip route add 178.154.239.0/24   via 81.85.78.1 dev eth0 table wgshared
# Vk
ip route add 5.61.16.0/21       via 81.85.78.1 dev eth0 table wgshared
ip route add 5.61.232.0/21      via 81.85.78.1 dev eth0 table wgshared
ip route add 5.101.40.0/22      via 81.85.78.1 dev eth0 table wgshared
ip route add 83.166.228.0/22    via 81.85.78.1 dev eth0 table wgshared
ip route add 83.166.252.0/24    via 81.85.78.1 dev eth0 table wgshared
ip route add 87.240.128.0/18    via 81.85.78.1 dev eth0 table wgshared
ip route add 93.186.224.0/20    via 81.85.78.1 dev eth0 table wgshared
ip route add 95.142.192.0/20    via 81.85.78.1 dev eth0 table wgshared
ip route add 95.213.0.0/17      via 81.85.78.1 dev eth0 table wgshared
ip route add 185.32.248.0/22    via 81.85.78.1 dev eth0 table wgshared
# vkusnoitochka
ip route add 185.65.149.0/24    via 81.85.78.1 dev eth0 table wgshared
# wb
ip route add 185.62.202.0/24    via 81.85.78.1 dev eth0 table wgshared
# ozon
ip route add 185.73.194.0/24    via 81.85.78.1 dev eth0 table wgshared
ip route add 185.73.193.0/24    via 81.85.78.1 dev eth0 table wgshared
# emias
ip route add 82.202.189.0/24    via 81.85.78.1 dev eth0 table wgshared
# vkusvil
ip route add 178.248.232.0/24   via 81.85.78.1 dev eth0 table wgshared
# perekrestok
ip route add 109.238.90.0/24    via 81.85.78.1 dev eth0 table wgshared
# mail
ip route add 185.180.200.0/22   via 81.85.78.1 dev eth0 table wgshared
ip route add 90.156.232.0/21    via 81.85.78.1 dev eth0 table wgshared
ip route add 89.221.236.0/22    via 81.85.78.1 dev eth0 table wgshared
# mts
ip route add 178.248.238.0/24   via 81.85.78.1 dev eth0 table wgshared
# beeline
ip route add 217.118.87.0/24    via 81.85.78.1 dev eth0 table wgshared
# dns-shop
ip route add 185.65.148.0/24    via 81.85.78.1 dev eth0 table wgshared
# mvideo
ip route add 185.71.67.0/24     via 81.85.78.1 dev eth0 table wgshared
# citilink
ip route add 178.248.234.0/24   via 81.85.78.1 dev eth0 table wgshared
# kinopoisk
ip route add 213.180.199.0/24   via 81.85.78.1 dev eth0 table wgshared
# dota2-russia (Stockholm, RU/EEU кластер)
ip route add 185.25.180.0/23    via 81.85.78.1 dev eth0 table wgshared
# ru-tinkoff-mobile-1-mnt
ip route add 178.130.128.0/24   via 81.85.78.1 dev eth0 table wgshared
# sber-services
ip route add 194.54.15.0/24     via 81.85.78.1 dev eth0 table wgshared
# tapper
ip route add 37.143.11.0/24     via 81.85.78.1 dev eth0 table wgshared
ip route add 217.144.98.231     via 81.85.78.1 dev eth0 table wgshared
# pachca.com
ip route add 37.200.70.176      via 81.85.78.1 dev eth0 table wgshared
# app.pachca.com
ip route add 91.105.198.132     via 81.85.78.1 dev eth0 table wgshared
# matchtv (GPM Digital Technologies + CDN)
ip route add 95.181.176.0/21    via 81.85.78.1 dev eth0 table wgshared
ip route add 194.190.130.0/24   via 81.85.78.1 dev eth0 table wgshared
ip route add 193.232.148.0/22   via 81.85.78.1 dev eth0 table wgshared
ip route add 194.190.76.0/23    via 81.85.78.1 dev eth0 table wgshared
ip route add 194.226.110.0/24   via 81.85.78.1 dev eth0 table wgshared
ip route add 91.207.58.0/23     via 81.85.78.1 dev eth0 table wgshared

# Route all VPN clients through wgshared for Russian routes (prio 50)
ip rule add from 10.2.0.0/24 prio 50 lookup wgshared

# Per-user ip rules → per-user routing table (prio 100)
# Table ID = 200 + last octet of client IP (e.g. 10.2.0.5 → table 205)
# Default route in each table is set by awg-hub-router.service after tunnels are up
while IFS= read -r N; do
    ip rule add from "10.2.0.$N" prio 100 lookup "$((200 + N))"
done < <(grep -oP 'AllowedIPs = 10\.2\.0\.\K\d+(?=/32)' "$AWG0_CONF")
