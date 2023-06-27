#! /bin/bash

# Install tools
yum update -y
yum install -y python3
rm -rf /usr/bin/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -b

# Install Web Server
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

## Enable tls
yum install -y mod_ssl
/etc/pki/tls/certs/make-dummy-cert /etc/pki/tls/certs/localhost.crt
sed -i 's/SSLCertificateKeyFile/#SSLCertificateKeyFile/' /etc/httpd/conf.d/ssl.conf
systemctl restart httpd

## Install Wordpress
wget https://wordpress.org/latest.tar.gz && tar -xzf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i 's/database_name_here/wordpress_db/; s/username_here/wordpress_user/; s/password_here/${GeneratePassword.RandomString}/; s/'\''DB_HOST'\'', '\''localhost'\''/'\''DB_HOST'\'', '\''${DatabaseServerPrivateIp}'\''/' wordpress/wp-config.php
mkdir /var/www/html/blog && cp -r wordpress/* /var/www/html/blog/
