# Scaling your encryption at rest capabilities with AWS KMS

Download CloudFormation Stack

```bash
curl 'https://static.us-east-1.prod.workshops.aws/public/d304bb25-9e99-4dee-a481-388ca2474a93/static/EnvironmentTemplate.yaml' --output template.yaml
```


arn:aws:s3:::workshop-kms-s3-cloudtrail-569651145632
Bucket Policy

```bash
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "DenyIncorrectEncryptionHeader",
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::workshop-kms-s3-cloudtrail-569651145632/*",
			"Condition": {
				"StringNotEquals": {
					"s3:x-amz-server-side-encryption": "aws:kms"
				}
			}
		},
		{
			"Sid": "AWSCloudTrailBucketAuthorization",
			"Effect": "Allow",
			"Principal": {
				"Service": "cloudtrail.amazonaws.com"
			},
			"Action": "s3:GetBucketAcl",
			"Resource": "arn:aws:s3:::workshop-kms-s3-cloudtrail-569651145632"
		},
		{
			"Sid": " AllowCloudTrailDelivery",
			"Effect": "Allow",
			"Principal": {
				"Service": "cloudtrail.amazonaws.com"
			},
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::workshop-kms-s3-cloudtrail-569651145632/AWSLogs/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": "bucket-owner-full-control"
				}
			}
		}
	]
}
```

S3 Bucket Policy to grant access across account

```bash
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy1",
    "Statement": [
        {
            "Sid": "ExampleStmt1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::498289857405:root"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::workshop-kms-s3-cloudtrail-569651145632/*",
                "arn:aws:s3:::workshop-kms-s3-cloudtrail-569651145632"
            ]
        }
    ]
}
```


Using Athena to query CloudTrail Logs

```bash
SELECT useridentity.accountid, useridentity.arn, useridentity.invokedby, eventname, errorcode, errormessage FROM "default"."cloudtrail_logs_workshop_kms_s3_cloudtrail_<ACCOUNT_ID>", UNNEST(resources) t(res)
where
res.arn = 'arn:aws:kms:us-east-1:<ACCOUNT_ID>:key/<KMS_KEY_ID>'
AND readonly='false'
order by eventtime desc


SELECT useridentity.accountid, useridentity.arn, useridentity.invokedby, eventname, errorcode, errormessage FROM "default"."cloudtrail_logs_workshop_kms_s3_cloudtrail_<ACCOUNT_ID>", UNNEST(resources) t(res)
where
res.arn = 'KMS Key ARN'
AND readonly='true'
order by eventtime desc limit 10


SELECT useridentity.accountid, useridentity.arn, useridentity.invokedby, eventname, errorcode, errormessage, 
json_extract(json_parse(requestparameters), '$.encryptionContext') as encryption_context
FROM "default"."cloudtrail_logs_workshop_kms_s3_cloudtrail_<ACCOUNT_ID>", 
UNNEST(resources) t(res)
where
readonly='true'
AND json_extract(json_parse(requestparameters), '$.encryptionContext') IS NOT NULL
order by eventtime desc


SELECT useridentity.accountid, useridentity.arn, useridentity.invokedby, eventname, errorcode, errormessage FROM "default"."cloudtrail_logs_workshop_kms_s3_cloudtrail_<ACCOUNT_ID>", UNNEST(resources) t(res)
where
res.arn = 'arn:aws:kms:us-east-1:<ACCOUNT_ID>:key/<KMS_KEY_ID>'
AND useridentity.accountid != '<ACCOUNT_ID>'
order by eventtime desc


```


KMS Policies

```bash
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::498289857405:root"
            },
            "Action": [
                "kms:Decrypt",
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "rds.us-east-1.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/KMS_Admin"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/ProjectRole"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/ProjectRole"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}





{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::498289857405:root"
            },
            "Action": "kms:Decrypt",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Enable S3 Batch Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/workshop-kms-s3-CloudTrailS3Batch-569651145632"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Enable CloudTrail Actions",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/TeamRole"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/TeamRole"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:role/TeamRole"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}


{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Allow use of the key with destination account",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::498289857405:root"
            },
            "Action": [
                "kms:Decrypt",
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "498289857405",
                    "kms:ViaService": "ec2.us-east-1.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::569651145632:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::569651145632:role/KMS_Admin",
                    "arn:aws:iam::569651145632:role/TeamRole",
                    "arn:aws:iam::569651145632:user/tu-dev"
                ]
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::569651145632:role/TeamRole",
                    "arn:aws:iam::569651145632:user/tu-dev"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::569651145632:role/TeamRole",
                    "arn:aws:iam::569651145632:user/tu-dev"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}


Lambda Function for generating S3 inventory for S3 Batch Operation

```bash


```