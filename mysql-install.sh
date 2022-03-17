#!/bin/bash
# setting up as private network with NAT gateway, need to set default route on instance


# Current script is running as root
# Below creates random password to be used in mysql setup

export DEBIAN_FRONTEND=noninteractive

MYSQL_ROOT_PASSWORD=`date |md5sum |cut -c '1-12'` # generates random password

# Install MySQL
echo debconf mysql-server/root_password password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
echo debconf mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
apt-get -qq install mysql-server > /dev/null # Install MySQL quietly

# # Install Expect
# apt-get -qq install expect > /dev/null

# # Build Expect script
# tee ~/secure_our_mysql.sh > /dev/null << EOF
# spawn $(which mysql_secure_installation)

# expect "Enter password for user root:"
# send "$MYSQL_ROOT_PASSWORD\r"

# expect "Press y|Y for Yes, any other key for No:"
# send "y\r"

# expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
# send "2\r"

# expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
# send "n\r"

# expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
# send "y\r"

# expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
# send "y\r"

# expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
# send "y\r"

# expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
# send "y\r"

# EOF

# # Run Expect script.
# # This runs the "mysql_secure_installation" script which removes insecure defaults.
# expect ~/secure_our_mysql.sh

# # Cleanup
# rm -v ~/secure_our_mysql.sh # Remove the generated Expect script
# #sudo apt-get -qq purge expect > /dev/null # Uninstall Expect, commented out in case you need Expect

echo "Binding MYSQL to all interfaces"

sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# create wordpress database, username and password

echo "Creating MySQL user and database"

/usr/bin/mysql -u root -e "CREATE DATABASE $db_name"
/usr/bin/mysql -u root -e "CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_password';"
/usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%';"

echo "done"

service mysql restart

echo "MySQL setup completed. Insecure defaults are gone."

echo "Your MYSQL root password has been set to="$MYSQL_ROOT_PASSWORD

