# AWS Security Best Practices

```bash
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0
sudo sysctl -w net.ipv4.route.flush=1

echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf

```

user data

```bash
#!/bin/bash
useradd -m webuser -g users
```

```bash
getent passwd webuser
```


## Security Monitoring

Configure and use AWS CloudWatch to monitor Security incidents. Use AWS CloudWatch Alarm and notification to alert on a specified number of login failures on your EC2 instances. Create CloudWatch alarm and notification to monitor traffic through a NAT gateway.

For the this lab the database server is access using systems manager session manager, cloudwatch agent is install and configured to send logs to aws CloudWatch. To test, attempt to login using a user `dbdev` whose password is unknown, just use any password.


```bash
sudo yum install -y amazon-cloudwatch-agent       # Install the cloudwatch agent on the instance
sudo setfacl -m u:cwagent:rx /var/log/secure      # Grant the cwagent user rx right to the log file you which to send to cloudwatch
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard   ## Configure the cloudwatch agent

## Start the cloudwatch agent - to start monitoring
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json 

## Check the cloudwatch agent status
systemctl status amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```

Sample Cloudwatch Configuration

```bash
{
        "agent": {
                "metrics_collection_interval": 30,
                "run_as_user": "cwagent"
        },
        "logs": {
                "logs_collected": {
                        "files": {
                                "collect_list": [
                                        {
                                                "file_path": "/var/log/secure",
                                                "log_group_name": "database_server_security_logs",
                                                "log_stream_name": "{instance_id}",
                                                "retention_in_days": 90
                                        }
                                ]
                        }
                }
        },
        "metrics": {
                "aggregation_dimensions": [
                        [
                                "InstanceId"
                        ]
                ],
                "append_dimensions": {
                        "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
                        "ImageId": "${aws:ImageId}",
                        "InstanceId": "${aws:InstanceId}",
                        "InstanceType": "${aws:InstanceType}"
                },
                "metrics_collected": {
                        "disk": {
                                "measurement": [
                                        "used_percent"
                                ],
                                "metrics_collection_interval": 30,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 30
                        }
                }
        }
}
```

To create alerts

From the log group in cloudwatch > metric filter > Create Metric Filter

Create metric pattern, type `"authentication failure"`
