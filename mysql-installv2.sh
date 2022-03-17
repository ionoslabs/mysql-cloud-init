#!/bin/bash

echo "Creating MySQL user and database"

/usr/bin/mysql -u root -e "CREATE DATABASE $db_name"
/usr/bin/mysql -u root -e "CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_password';"
/usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%';"

echo "done"



# secure Mysql installation

echo "changing bind address"

sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql restart