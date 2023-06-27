# Reliability

Setup

```bash
export awsAccount=`aws sts get-caller-identity --query "Account" --output text` && echo awsAccount=$awsAccount >> ~/.bashrc
export awsRegion=`curl -s http://169.254.169.254/latest/meta-data/placement/region` && echo awsRegion=$awsRegion >> ~/.bashrc
export VPC=`aws ec2 describe-vpcs --filters Name=tag:Name,Values=wa-lab-vpc --query 'Vpcs[*].VpcId' --output text --region $awsRegion` && echo VPC=$VPC >> ~/.bashrc
export awsAZ1=`aws ec2 describe-availability-zones --region $awsRegion --query 'AvailabilityZones[].ZoneName[]|[0]' --output text` && echo awsAZ1=$awsAZ1 >> ~/.bashrc
export awsAZ2=`aws ec2 describe-availability-zones --region $awsRegion --query 'AvailabilityZones[].ZoneName[]|[1]' --output text` && echo awsAZ2=$awsAZ2 >> ~/.bashrc

aws ec2 create-subnet --vpc-id $VPC --cidr-block "10.100.2.0/24" --availability-zone $awsAZ2 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=wa-public-subnet-2}]' --region $awsRegion
aws ec2 create-subnet --vpc-id $VPC --cidr-block "10.100.3.0/24" --availability-zone $awsAZ2 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=wa-private-subnet-2}]' --region $awsRegion

export publicSubnetId=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-public-subnet-2 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo publicSubnetId=$publicSubnetId >> ~/.bashrc


export publicRt=`aws ec2 describe-route-tables --filters Name=tag:Name,Values=wa-public-rt --query 'RouteTables[*].RouteTableId' --output text --region $awsRegion` && echo publicRt=$publicRt >> ~/.bashrc
export privateRt=`aws ec2 describe-route-tables --filters Name=tag:Name,Values=wa-private-rt --query 'RouteTables[*].RouteTableId' --output text --region $awsRegion` && echo privateRt=$privateRt >> ~/.bashrc


aws ec2 associate-route-table --subnet-id $publicSubnetId --route-table-id $publicRt --region $awsRegion
aws ec2 associate-route-table --subnet-id $privateSubnetId --route-table-id $privateRt --region $awsRegion

# Create RDS Subnet
aws ec2 create-subnet --vpc-id $VPC --cidr-block "10.100.4.0/24" --availability-zone $awsAZ1 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=wa-rds-subnet-1}]' --region $awsRegion
aws ec2 create-subnet --vpc-id $VPC --cidr-block "10.100.5.0/24" --availability-zone $awsAZ2 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=wa-rds-subnet-2}]' --region $awsRegion

export rdsSubnet1Id=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-rds-subnet-1 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo rdsSubnet1Id=$rdsSubnet1Id >> ~/.bashrcexport rdsSubnet2Id=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-rds-subnet-2 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo rdsSubnet1Id=$rdsSubnet2Id >> ~/.bashrc

aws ec2 associate-route-table --subnet-id $rdsSubnet1Id --route-table-id $privateRt --region $awsRegion
aws ec2 associate-route-table --subnet-id $rdsSubnet2Id --route-table-id $privateRt --region $awsRegion

aws rds create-db-subnet-group --db-subnet-group-name "wa-rds-subnet-group" --db-subnet-group-description "WA RDS Subnet Group" --subnet-ids $rdsSubnet1Id $rdsSubnet2Id --region $awsRegion

aws ec2 create-security-group --description "RDS Security group" --group-name "wa-rds-sg" --vpc-id $VPC --region $awsRegion

export rdsSg=`aws ec2 describe-security-groups --filters Name=group-name,Values=wa-rds-sg --query 'SecurityGroups[*].GroupId' --output text --region $awsRegion` && echo rdsSg=$rdsSg >> ~/.bashrc
export ec2DbSg=`aws ec2 describe-security-groups --filters Name=group-name,Values=wa-database-sg --query 'SecurityGroups[*].GroupId' --output text --region $awsRegion` && echo ec2DbSg=$ec2DbSg >> ~/.bashrc

aws ec2 authorize-security-group-ingress --group-id $rdsSg --source-group $ec2DbSg --protocol "tcp" --port "3306" --region $awsRegion 


## Create RDS instance
aws rds create-db-instance --db-name "WaRdsDb" --db-instance-identifier "waDbInstance" --allocated-storage 20 --db-instance-class db.t2.micro --engine "mariadb" --master-username "mainuser" --master-user-password "WaStr0ngP4ssw0rd" --vpc-security-group-ids $rdsSg --db-subnet-group-name "wa-rds-subnet-group" --multi-az --no-publicly-accessible --backup-retention-period 0 --region $awsRegion

# Get DB Instance Endpoint
aws rds describe-db-instances --db-instance-identifier "waDbInstance" --query 'DBInstances[*].Endpoint.Address' --output text --region $awsRegion

# Get DbPrivateDns
aws ssm get-parameters --names "DbPrivateDns" --region $awsRegion --output table
aws ssm get-parameters --names "DbPrivateDns" --region $awsRegion --query "Parameters[*].Value" --output table
aws ssm get-parameters --names "DbPrivateDns" --query "Parameters[*].Value" --region $awsRegion --output text

export rdsEndPoint=`aws rds describe-db-instances --db-instance-identifier "waDbInstance" --query "DBInstances[*].Endpoint.Address" --output text --region $awsRegion` && echo rdsEndPoint=$rdsEndPoint >> ~/.bashrc

aws ssm put-parameter --name "DbPrivateDns" --value $rdsEndPoint --overwrite --region $awsRegion

aws ssm get-parameters --name DbPrivateDns --region $awsRegion --query "Parameters[*].Value"  --output text   # or
aws ssm get-parameters --name DbPrivateDns --region $awsRegion --query "Parameters[1].Value"  --output text


# Create security group for alb
aws ec2 create-security-group --description "ALB Security group" --group-name "wa-alb-sg" --vpc-id $VPC --region $awsRegion
export albSg=`aws ec2 describe-security-groups --filters Name=group-name,Values=wa-alb-sg --query 'SecurityGroups[*].GroupId' --output text --region $awsRegion` && echo albSg=$albSg >> ~/.bashrc
aws ec2 authorize-security-group-ingress --group-id $albSg --protocol "tcp" --port "80" --cidr "0.0.0.0/0" --region $awsRegion

export albSubnet1Id=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-public-subnet-1 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo albSubnet1Id=$albSubnet1Id >> ~/.bashrc

export albSubnet2Id=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-public-subnet-2 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo albSubnet1Id=$albSubnet2Id >> ~/.bashrc

aws elbv2 create-load-balancer --name "waAlb" --subnets $albSubnet1Id $albSubnet2Id --security-group $albSg --type "application" --region $awsRegion

aws elbv2 create-target-group --name "waAutoscale-tg" --protocol "HTTP" --port 80 --vpc-id $VPC --target-type "instance" --region $awsRegion

export waTg=`aws elbv2 describe-target-groups --name waAutoscale-tg --query 'TargetGroups[*].TargetGroupArn' --output text --region $awsRegion` && echo waTg=$waTg >> ~/.bashrc

export albArn=`aws elbv2 describe-load-balancers --name waAlb --query 'LoadBalancers[*].LoadBalancerArn' --output text --region $awsRegion` && echo albArn=$albArn >> ~/.bashrc

# Download a template listener.json file 

wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/ILT-TF-200-CSAWAF-10-EN/listener-source.json

# File Content

[
    {
        "Type": "forward",
        "TargetGroupArn": "$waTg",
        "Order": 1
    }
]


envsubst < "listener-source.json" > listener.json     # Substitute env for $waTg

# Create Listener
aws elbv2 create-listener --load-balancer-arn $albArn --protocol "HTTP" --port 80 --default-actions file://listener.json --region $awsRegion

# confirm rds is fully deployed
aws rds describe-db-instances --db-instance-identifier "waDbInstance" --query 'DBInstances[*].{DB_Identifier:DBInstanceIdentifier,Status:DBInstanceStatus}' --output table --region $awsRegion


# Shell comand to run on systems manager AWS-RunShellScript

#!/bin/bash
# Database backup using mysqldump utility
mysqldump sample > backup.sql
# Add RDS endpoint as an environment variable
export awsRegion=`curl -s http://169.254.169.254/latest/meta-data/placement/region`
export rdsendpoint=`aws ssm get-parameter --name DbPrivateDns --query 'Parameter.Value' --region $awsRegion --output text`
# Set RDS instance admin user variable
export user=mainuser
# Set the RDS admin password value stored in Secrets Manager as variable
export rdspasswd=`aws secretsmanager get-secret-value --secret-id rdsPassword --query 'SecretString' --output text --region $awsRegion`
# Below commands creates database, loads MySQL backup into RDS, creates a user and set permissions in RDS database instance
mysql -h $rdsendpoint -u $user -p$rdspasswd -e "CREATE DATABASE sample;"
mysql -h $rdsendpoint -u $user -p$rdspasswd -e "USE sample;source backup.sql;"
mysql -h $rdsendpoint -u $user -p$rdspasswd -e "CREATE USER 'tutorial_user'@'%' IDENTIFIED BY 'WaFram3w0rk';"
mysql -h $rdsendpoint -u $user -p$rdspasswd -e "GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'tutorial_user'@'%' WITH GRANT OPTION;"
mysql -h $rdsendpoint -u $user -p$rdspasswd -e "FLUSH PRIVILEGES;"



# Create SG For autoscaling group

aws ec2 create-security-group --description "Launch Template Security group" --group-name "wa-asg-sg" --vpc-id $VPC --region $awsRegion

export asgSg=`aws ec2 describe-security-groups --filters Name=group-name,Values=wa-asg-sg --query 'SecurityGroups[*].GroupId' --region $awsRegion --output text` && echo asgSg=$asgSg >> ~/.bashrc

aws ec2 authorize-security-group-ingress --group-id $asgSg --source-group $albSg --protocol "tcp" --port 80 --region $awsRegion
aws ec2 authorize-security-group-ingress --group-id $rdsSg --source-group $asgSg --protocol "tcp" --port "3306" --region $awsRegion

# Get IAM of current web server

export webAMI=`aws ec2 describe-instances --region $awsRegion --filters "Name=tag:Name,Values=wa-web-server" --query Reservations[].Instances[].ImageId[] --output=text` && echo webAMI=$webAMI >> ~/.bashrc

## Download userdata
wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/ILT-TF-200-CSAWAF-10-EN/userData-source.sh   


# The download userdata

#!/bin/bash
#Installs & Updates
yum update -y
amazon-linux-extras install -y epel lamp-mariadb10.2-php7.2 php7.2
yum install stress -y
yum install -y httpd
chkconfig httpd on
systemctl start httpd

#Db Info
mkdir /var/www/inc
cd /var/www/inc
wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/ILT-TF-200-CSAWAF-10-EN/dbinfo-source.inc
export rdsEndpoint=`aws ssm get-parameter --name DbPrivateDns --query 'Parameter.Value' --region  $awsRegion --output text`
envsubst < dbinfo-source.inc > dbinfo.inc
rm -f dbinfo-source.inc

#PHP App
cd /var/www/html
wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/ILT-TF-200-CSAWAF-10-EN/website.zip
unzip website.zip
rm -f website.zip
sudo chown -R root:apache /var/www

#ASG Trigger
stress --cpu 8 --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1 --timeout 180s


# Substitute enviroment variables
envsubst < userData-source.sh > userData.sh
export userData=`base64 userData.sh  | tr -d "\n"` && echo userData=$userData >> ~/.bashrc

# Download template for launch Template configuration
wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/ILT-TF-200-CSAWAF-10-EN/waLaunchTemplate-source.json-v1.1.0

cat waLaunchTemplate-source.json-v1.1.0 

{
    "IamInstanceProfile": {
        "Name": "wa-asg-instance-profile"
    },
    "ImageId": "$webAMI",
    "InstanceType": "t3.micro",
    "Monitoring": {
        "Enabled": true
    },
    "UserData": "$userData",
    "TagSpecifications": [
        {
            "ResourceType": "instance",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "wa-auto-scale-group"
                }
            ]
        }
    ],
    "SecurityGroupIds": [ "$asgSg" ]
}



envsubst < waLaunchTemplate-source.json-v1.1.0 > waLaunchTemplate.json
aws ec2 create-launch-template --launch-template-name "waLaunchTemplate" --launch-template-data file://waLaunchTemplate.json --region $awsRegion

export waLaunchTemplate=`aws ec2 describe-launch-templates --launch-template-names waLaunchTemplate --query 'LaunchTemplates[*].LaunchTemplateId' --output text --region $awsRegion` && echo waLaunchTemplate=$waLaunchTemplate >> ~/.bashrc

export asgSubnet1Id=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-private-subnet-1 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo asgSubnet1Id=$asgSubnet1Id >> ~/.bashrc

export asgSubnet2Id=`aws ec2 describe-subnets --filters Name=tag:Name,Values=wa-private-subnet-2 --query 'Subnets[*].SubnetId' --output text --region $awsRegion` && echo asgSubnet2Id=$asgSubnet2Id >> ~/.bashrc

aws autoscaling create-auto-scaling-group --auto-scaling-group-name "waAutoscaleGroup" --launch-template LaunchTemplateId=$waLaunchTemplate --min-size "2" --max-size "4" --target-group-arns $waTg --vpc-zone-identifier "$asgSubnet1Id,$asgSubnet2Id" --region $awsRegion


# Check running intances
aws ec2 describe-instances --filters Name=tag:Name,Values=wa-auto-scale-group --query 'Reservations[].Instances[*].{InstanceID:InstanceId,Type:InstanceType,AZ:Placement.AvailabilityZone,PrivateIP:PrivateIpAddress,Subnet:SubnetId,Time:LaunchTime,State:State.Name}' --output table --region $awsRegion

# Ternminate an instance to text autoscaling
aws ec2 terminate-instances --region $awsRegion --instance-ids YOUR_INSTANCE_ID
```
