# Cost Optimization

DeveloperGroup Iam policy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:Describe*"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "AllowToDescribeAll"
        },
        {
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateVolume"
            ],
            "Resource": [
                "arn:aws:ec2:*::image/*",
                "arn:aws:ec2:*::snapshot/*",
                "arn:aws:ec2:*:*:subnet/*",
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:security-group/*",
                "arn:aws:ec2:*:*:key-pair/*",
                "arn:aws:ec2:*:*:volume/*"
            ],
            "Effect": "Allow",
            "Sid": "AllowRunInstances"
        },
        {
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "Development",
                    "aws:RequestTag/CostCenter": "CC1",
                    "ec2:InstanceType": "t3.small"
                }
            },
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Effect": "Allow",
            "Sid": "AllowRunInstancesWithRestrictions"
        },
        {
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "RunInstances"
                }
            },
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:network-interface/*"
            ],
            "Effect": "Allow",
            "Sid": "AllowCreateTagsOnlyLaunching"
        },
        {
            "Condition": {
                "NumericLessThanEqualsIfExists": {
                    "ec2:VolumeSize": "8"
                },
                "StringNotEqualsIgnoreCaseIfExists": {
                    "ec2:VolumeType": [
                        "io1",
                        "st1"
                    ]
                }
            },
            "Action": "ec2:CreateVolume",
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "costPrev1"
        },
        {
            "Action": [
                "ec2:*Purchase*",
                "ec2:*ReservedInstances*",
                "ec2:*Scheduled*",
                "ec2:*Spot*",
                "ec2:EnableFastSnapshotRestores"
            ],
            "Resource": "*",
            "Effect": "Deny",
            "Sid": "costPrev2"
        },
        {
            "Condition": {
                "StringNotEqualsIgnoreCase": {
                    "ec2:Owner": "amazon"
                }
            },
            "Action": "ec2:RunInstances",
            "Resource": "arn:aws:ec2:*:*:image/*",
            "Effect": "Deny",
            "Sid": "costPrev3"
        },
        {
            "Condition": {
                "ForAnyValue:StringEqualsIgnoreCase": {
                    "ec2:ResourceTag/AMI-TYPE": "Paid"
                }
            },
            "Action": "ec2:RunInstances",
            "Resource": "arn:aws:ec2:*::image/ami-*",
            "Effect": "Deny",
            "Sid": "costPrev4"
        },
        {
            "Condition": {
                "ForAnyValue:StringEqualsIgnoreCase": {
                    "ec2:ResourceTag/AMI-TYPE": "Paid"
                }
            },
            "Action": "ec2:RunScheduledInstances",
            "Resource": "arn:aws:ec2:*::image/ami-*",
            "Effect": "Deny",
            "Sid": "costPrev5"
        }
    ]
}
```
