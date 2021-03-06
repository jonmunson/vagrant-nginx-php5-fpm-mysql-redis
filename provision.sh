#! /usr/bin/env bash
 
# variables
DBNAME=project_name
DBUSER=project_user
DBPASSWD=supersecurepass

# set locale
locale-gen UTF-8

# add repos for latest php, nginx & redis
echo -e "\n--- Add repos for latest PHP, Nginx & Redis ---\n"
sudo add-apt-repository -y ppa:nginx/stable > /dev/null 2>&1
sudo add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
sudo add-apt-repository ppa:chris-lea/redis-server > /dev/null 2>&1

# base
echo -e "\n--- Install essential packages ---\n"
sudo apt-key update > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y git htop curl wget sqlite build-essential python-software-properties > /dev/null 2>&1

# nginx
echo -e "\n--- Install Nginx ---\n"
sudo apt-get install -y nginx > /dev/null 2>&1

# php
echo -e "\n--- Install PHP ---\n"
sudo apt-get install --force-yes -y php5 php5-cli php5-curl php5-gd php5-mcrypt php5-xdebug php5-fpm php-db php5-mysql > /dev/null 2>&1

# php-fpm config
echo -e "\n--- PHP config ---\n"
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini > /dev/null 2>&1
sudo sed -i "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/" /etc/php5/fpm/pool.d/www.conf > /dev/null 2>&1
sudo sed -i "s/;listen.owner = www-data/listen.owner = www-data/" /etc/php5/fpm/pool.d/www.conf > /dev/null 2>&1
sudo sed -i "s/listen.group = www-data/listen.group = www-data/" /etc/php5/fpm/pool.d/www.conf > /dev/null 2>&1
sudo sed -i "s/listen.mode = 0660/listen.mode = 0660/" /etc/php5/fpm/pool.d/www.conf > /dev/null 2>&1
sudo service php5-fpm restart  > /dev/null 2>&1
sudo chown www-data:www-data /var/run/php5-fpm.sock > /dev/null 2>&1

# nginx config
echo -e "\n--- Nginx config ---\n"
sudo rm -f /etc/nginx/sites-enabled/default > /dev/null 2>&1
sudo cp /var/www/Vagrant-config/server /etc/nginx/sites-enabled/default > /dev/null 2>&1
sudo rm -f /etc/nginx/nginx.conf > /dev/null 2>&1
sudo cp /var/www/Vagrant-config/nginx.conf /etc/nginx/nginx.conf > /dev/null 2>&1
sudo service nginx restart > /dev/null 2>&1

# redis
echo -e "\n--- Install Redis ---\n"
sudo apt-get install -y redis-server > /dev/null 2>&1

# mysql
echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get -y install mysql-server-5.5 > /dev/null 2>&1
 
# mysql config
echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

