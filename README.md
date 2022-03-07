# mysql-cloud-init

This project is used to build a mysql server instance on ubuntu 20.04 LTS via secure install in the IONOS environment
The Yaml file installs apache2 (for future use) and then clones the repo to /tmp in order to run
the mysql-install.sh script
The installer also creates a random password which is echo'd out at the completion of the install

Use the fir