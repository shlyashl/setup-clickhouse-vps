#!/bin/sh

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list

yes 2>/dev/null | sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq install clickhouse-server clickhouse-client

# разрешить слушать внешний трафик
sudo sed -i -e "s/<\!-- <listen_host>::<\/listen_host> -->/<listen_host>::<\/listen_host>/g" /etc/clickhouse-server/config.xml

# разрешить пользователю default обращаться только локально
sudo sed -i -e "s/<ip>::\/0<\/ip>/<ip>::1<\/ip><ip>127.0.0.1<\/ip>/g" /etc/clickhouse-server/users.xml

# разрешить пользователю default использовать DCL
sudo sed -i -e "s/<\!-- <access_management>1<\/access_management> -->/<access_management>1<\/access_management>/g" /etc/clickhouse-server/users.xml

sudo service clickhouse-server start
