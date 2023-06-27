# Application Migration with AWS Application Migration Service

```bash
cd
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install httpd -y
systemctl enable httpd.service
systemctl start httpd
cd /var/www/html
wget  https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-200-PTMIGS/v3.1.1.prod-75afe467/lab-2/scripts/instanceData.zip
unzip  instanceData.zip
```


```bash
# Download the installer using this command
wget -O ./aws-replication-installer-init.py https://aws-application-migration-service-us-west-2.s3.us-west-2.amazonaws.com/latest/linux/aws-replication-installer-init.py


# Copy and input the command below into the command line on your source server
sudo python3 aws-replication-installer-init.py --region us-west-2 --aws-access-key-id AKIAQPOBXYWKM63N2IRZ --aws-secret-access-key Y3Y8nLtScuQyBENVGuzo6UJEzWHT1eYsOHGQFRva --no-prompt
```

IAM Roles created for MGN

Service Linked Role

- AWSServiceRoleForApplicationMigrationService

Service Roles

- AWSApplicationMigrationReplicationServerRole
- AWSApplicationMigrationConversionServerRole
- AWSApplicationMigrationMGHRole
- AWSApplicationMigrationLaunchInstanceWithSsmRole
- AWSApplicationMigrationLaunchInstanceWithDrsRole
- AWSApplicationMigrationAgentRole

Download the installer using this command:

```bash
wget -O ./aws-replication-installer-init.py https://aws-application-migration-service-us-west-2.s3.us-west-2.amazonaws.com/latest/linux/aws-replication-installer-init.py
```

```bash
sudo python3 aws-replication-installer-init.py --region us-west-2 --aws-access-key-id AKIAYXJCMHMWWFWD6WF4 --aws-secret-access-key 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 --no-prompt
```


```bash
sudo yum update -y &&
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2 &&
sudo yum install -y httpd &&
sudo systemctl enable httpd.service
sudo systemctl start httpd
cd /var/www/html
sudo wget  https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-200-PTMIGS/v3.1.1.prod-75afe467/lab-2/scripts/instanceData.zip
sudo unzip instanceData.zip
```

Add the replication agent to the source

```bash
wget -O ./aws-replication-installer-init.py https://aws-application-migration-service-us-west-2.s3.us-west-2.amazonaws.com/latest/linux/aws-replication-installer-init.py


sudo python3 aws-replication-installer-init.py --region us-west-2 --aws-access-key-id AKIA3MV4GF3SSDUJJLNR --aws-secret-access-key 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 --no-prompt
```