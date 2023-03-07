#!/bin/sh

sudo apt-get update

sudo apt-get install -y net-utils
sudo apt-get install -y iptables
sudo apt-get install -y netfilter-persistent
sudo apt install -y iptables-persistent

# сбросить все настройки
sudo iptables -F
sudo iptables -t nat -F

# разрешить переброску пакетов между
# сетевыми интерфейсами
sudo sysctl -w net.ipv4.ip_forward="1"

# перебросить пакеты из локалки во внешний интерфейс,
# у меня он называется "ens3" ("ip add" для проверки имени)
sudo iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE

# открыть порты для входящего трафика
sudo iptables -t filter -A INPUT -i ens3 -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp -m multiport --dports 8123,9099,9001,5115,8118,4337,5000,80,442,8321 -j ACCEPT

# открыть весь исходящий трафик
sudo iptables -A INPUT -j ACCEPT -i lo
sudo iptables -A INPUT -j ACCEPT -m state --state RELATED,ESTABLISHED

# закрыть отсальные порты для входящего трафика
sudo iptables -A INPUT -m conntrack -j ACCEPT  --ctstate RELATED,ESTABLISHED
sudo iptables -A INPUT -j DROP
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -j DROP

# сохраняем правила
sudo netfilter-persistent save
sudo service netfilter-persistent save
