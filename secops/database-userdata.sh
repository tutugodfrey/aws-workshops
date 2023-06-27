#! /bin/bash

yum update -y
yum install -y python3
rm -rf /usr/bin/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -b

# Configure mariadb
amazon-linux-extras install -y mariadb10.5
sed -i 's/#bind-address/bind-address/' /etc/my.cnf.d/mariadb-server.cnf
systemctl enable mariadb && systemctl start mariadb
mysqladmin --user=root password "${GeneratePassword.RandomString}"
mysql -e "DROP USER IF EXISTS ''@'localhost'"
mysql -e "DROP DATABASE IF EXISTS test"
mysql -e "CREATE DATABASE IF NOT EXISTS wordpress_db"
mysql -e "CREATE USER IF NOT EXISTS 'wordpress_user'@'${WebServerPrivateIp}' IDENTIFIED BY '${GeneratePassword.RandomString}'"
mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* to 'wordpress_user'@'${WebServerPrivateIp}'"
mysql -e "FLUSH PRIVILEGES"
