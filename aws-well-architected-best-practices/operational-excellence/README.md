# Operational Excellence


System management Run Commands

```bash
AWS-ConfigureAWSPackage  (Package to install - AmazonCloudWatchAgent)
AmazonCloudWatch-ManageAgent (action configure)
```

AmazonCloudWatch-ManageAgent specify wa-cw-config-file-httpd-mariadb in Optional Configuration Location

CloudWatch Log configuration file created as ssm parameter `wa-cw-config-file-httpd-mariadb`

```bash
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "messages",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "httpd_access_log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/mariadb/wa-db-server.log",
            "log_group_name": "db_general_query_log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/mariadb/mariadb.log",
            "log_group_name": "mariadb_log",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    },
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "statsd": {
        "metrics_aggregation_interval": 60,
        "metrics_collection_interval": 10,
        "service_address": ":8125"
      }
    }
  }
}
```


AWS System Manager Documents

- AWS-ConfigureAWSPackage
- AmazonCloudWatch-ManageAgent
-


# Resources

[Working with SSM Agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html)

[Create an IAM Instance profile for Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html)

[Installing the CloudWatch agent on Amazon EC2 instances using the agent configuration](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance-fleet.html#download-CloudWatch-Agent-on-EC2-Instance-fleet)
