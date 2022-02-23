#!/usr/bin/env bash

sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install build-essential mysql-server libmysqlclient-dev npm -y

sudo mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('something');FLUSH PRIVILEGES;"

sudo mysql -e "DELETE FROM mysql.user WHERE User='';"

sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

sudo mysql -e "DROP DATABASE test;DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';"

sudo mysql -u root -psomething -e "CREATE USER 'ubuntu'@'localhost' IDENTIFIED BY 'something';GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'localhost';FLUSH PRIVILEGES;