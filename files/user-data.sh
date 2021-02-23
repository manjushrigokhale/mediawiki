#!/bin/bash
yum update -y
dnf module reset php -y 
dnf module enable php:7.4 -y
dnf install httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json -y
systemctl start mariadb
mysql -u root -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin.mediawiki';"
mysql -u root -e "CREATE DATABASE wikidatabase;"
mysql -u root -e "GRANT ALL PRIVILEGES ON wikidatabase.* TO 'admin'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"
systemctl enable mariadb
systemctl enable httpd
yum install wget -y
wget https://releases.wikimedia.org/mediawiki/1.35/mediawiki-1.35.1.tar.gz
wget https://releases.wikimedia.org/mediawiki/1.35/mediawiki-1.35.1.tar.gz.sig
gpg --verify mediawiki-1.35.1.tar.gz.sig mediawiki-1.35.1.tar.gz
tar -zxf mediawiki-1.35.1.tar.gz
mv mediawiki-1.35.1 /var/www/html/
cd /var/www/html/
ln -s mediawiki-1.35.1/ mediawiki
chown -R apache:apache /var/www/html/mediawiki-1.35.1
service httpd restart
restorecon -FR /var/www/html/mediawiki-1.35.1/
restorecon -FR /var/www/html/mediawiki/
