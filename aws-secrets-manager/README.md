# AWS Secrets Manager

[Workshop Guide](https://catalog.us-east-1.prod.workshops.aws/workshops/92e466fd-bd95-4805-9f16-2df07450db42/en-US/module2)

## Resources

[Get started with AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/getting-started.html#rotating-secrets-two-users)

[Set up alternating users rotation for AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_rotation-alternating.html)

[How to configure rotation and rotation windows for secrets stored in AWS Secrets Manager](https://aws.amazon.com/blogs/security/how-to-configure-rotation-windows-for-secrets-stored-in-aws-secrets-manager/)

[Amazon RDS announces integration with AWS Secrets Manager](https://aws.amazon.com/about-aws/whats-new/2022/12/amazon-rds-integration-aws-secrets-manager/)

Permission for Lambda function (Lambda Execution Role)

- AWSLambdaBasicExecutionRole
- AWSLambdaVPCAccessExecutionRole
- AllowInvoke (Custom)
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "lambda:InvokeFunction",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```
- AllowSM (Attribute Base Access Control)
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Event": "${aws:PrincipalTag/Event}",
                    "aws:ResourceTag/Workshop": "${aws:PrincipalTag/Workshop}"
                }
            },
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Trusted Entities

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

AWS EventBridge Rule

```bash
{
  "source": ["aws.config"],
  "detail-type": ["Config Rules Compliance Change"],
  "detail": {
    "configRuleName": ["secretsmanager-workshop-secret-unused", "secretsmanager-workshop-rotation-enabled-check", "secretsmanager-workshop-secret-periodic-rotation", "secretsmanager-workshop-scheduled-rotation-success-check", "secretsmanager-workshop-using-cmk"]
  }
}
```

Attributes

- Event Type: "Config Rules Compliance Change"
- Any Message Type
- Specific Rule Name(s)
- Any Resource Type
- Any Resource ID

Select SnsTopic for target and the topic
For additional setting select, under `Configure target input` select `input transformer`. Under `Target input transformer` paste text below

```bash
{"resource":"$.detail.resourceId","compliance":"$.detail.newEvaluationResult.complianceType","rule":"$.detail.configRuleName","time":"$.detail.newEvaluationResult.resultRecordedTime"}
```

Under template paste

```bash
"The compliance state of secret <resource> for rule <rule> has changed to <compliance> at <time>."
```

## Automation of Incident Response Workflows

EventBridge Rule to notify when resource policy is deleted

```bash
{
  "source": [
    "aws.secretsmanager"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "secretsmanager.amazonaws.com"
    ],
    "eventName": [
      "DeleteResourcePolicy"
    ]
  }
}
```

Input Transformer (Target Input Transformer)

```bash
{"AccessingParty":"$.detail.userIdentity.arn","EventTime":"$.detail.eventTime","Secret":"$.detail.responseElements.aRN"}
```

Input Transformer (Template)

```bash
"The Resource Policy of a secret <Secret> was attempted for deletion by <AccessingParty> on <EventTime>. "
```

Resource Policy for secrets manager secret

Before remediation

```bash
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*",
    "Condition" : {
      "ArnNotEquals" : {
        "aws:PrincipalArn" : [ "arn:aws:iam::454898608431:role/LambdaRDSTestRole", "arn:aws:iam::454898608431:role/mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I" ]
      }
    }
  } ]
}
```


After remediation

```bash
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*",
    "Condition" : {
      "ArnNotEquals" : {
        "aws:PrincipalArn" : [ "arn:aws:iam::454898608431:role/mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I", "arn:aws:iam::454898608431:role/LambdaRDSTestRole" ]
      }
    }
  }, {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : [ "secretsmanager:TagResource", "secretsmanager:UntagResource" ],
    "Resource" : "*"
  } ]
}
```

KMS CMK: AWSSecretsManagerWorkshopKey 

KMS Key Policy

```bash
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::454898608431:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:DescribeKey",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "454898608431",
                    "kms:ViaService": "secretsmanager.us-east-1.amazonaws.com"
                }
            }
        }
    ]
}
```


Secret Manager tags
Workshop: AWSSecretsManagerWorkshop



PASSWORD: notapassword
RDS_DB_NAME: DemoRDSDB
RDS_HOST: demordsdbinstance.cq0odovrwftm.us-east-1.rds.amazonaws.com
RDS_USERNAME: demouser

# Create role - RDSLambdaCFNInitRole

- AWSLambdaBasicExecutionRole
- AWSLambdaVPCAccessExecutionRole
- Custom Policy - LambdaExecutionPolicy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:DescribeVpcEndpointServices",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Trusted  Entity

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com"
                ]
            }
        }
    ]
}
```

Create Lambda Function - RDSInitLambda

Create a Role - SNSPortalLambdaRole
- Custom Policy - LambdaDDBExecutionPolicy
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:Scan"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Trusted Entities

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```
Create Function - SNSPortalLambdaFunction




## Create a role - LambdaRDSTestRole
- AWSLambdaVPCAccessExecutionRole
- AWSLambdaBasicExecutionRole
- Custom Policy - AllowInvoke

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "lambda:InvokeFunction",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

- Custom Policy - AllowSM

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Event": "${aws:PrincipalTag/Event}",
                    "aws:ResourceTag/Workshop": "${aws:PrincipalTag/Workshop}"
                }
            },
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```


Trusted Relationship
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com"
                ]
            }
        }
    ]
}
```


Create a Role - mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I

- AWSLambdaBasicExecutionRole
- AWSLambdaVPCAccessExecutionRole
- Custom Policy - SecretsManagerRDSMySQLRotationSingleUserRolePolicy0

```bash
{
    "Statement": [
        {
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DetachNetworkInterface"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

- Custom Policy - SecretsManagerRDSMySQLRotationSingleUserRolePolicy1

```bash
{
    "Statement": [
        {
            "Condition": {
                "StringEquals": {
                    "secretsmanager:resource/AllowRotationLambdaArn": "arn:aws:lambda:us-east-1:454898608431:function:SecretsManagerMySQLRotationLambda"
                }
            },
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:PutSecretValue",
                "secretsmanager:UpdateSecretVersionStage"
            ],
            "Resource": "arn:aws:secretsmanager:us-east-1:454898608431:secret:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "secretsmanager:GetRandomPassword"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

- Custom Policy - SecretsManagerRDSMySQLRotationSingleUserRolePolicy2

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:GenerateDataKey"
            ],
            "Resource": "arn:aws:kms:us-east-1:454898608431:key/31f0695f-bbd3-41e6-9d83-f302e4540150",
            "Effect": "Allow"
        }
    ]
}
```

Trusted Entiies

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com"
                ]
            }
        }
    ]
}
```

Create Role - UpdateSecretPolicyLambdaRole

- Custom Policy - LambdaExecutionPolicy2

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "secretsmanager:RotateSecret",
                "secretsmanager:PutResourcePolicy"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:AttachRolePolicy",
                "iam:AttachUserPolicy"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Trusted Entities

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com"
                ]
            }
        }
    ]
}
```
Create Function - UpdateSecretPolicyLambdaFunction




Create KMS CMK with alias AWSSecretsManagerWorkshopKey with key Policy below

```bash
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
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
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:DescribeKey",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "569651145632",
                    "kms:ViaService": "secretsmanager.us-east-1.amazonaws.com"
                }
            }
        }
    ]
}
```


## Create API Gateway

-  (secops) with REST API

## Create a DynamoDB Table

 SNSPortalDDB (On-Demand)

- Partition key - tablekey (String)
- Sort Key - message_ts (Number)

## Create RDS MySQL

DB identifier: demordsdbinstance
Master username: demouser
Password - Auto generated:  45z9FEv7k2ZO91BXMdQq
Initial Database name: DemoRDSDB
DB endpoint: demordsdbinstance.cniyl16rlvzp.us-west-2.rds.amazonaws.com

## Create rds secret in Secrets Manager


Initial Secret Resouce Policy

```bash
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*",
    "Condition" : {
      "ArnNotEquals" : {
        "aws:PrincipalArn" : [ "arn:aws:iam::454898608431:role/mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I", "arn:aws:iam::454898608431:role/LambdaRDSTestRole" ]
      }
    }
  } 
  ]
}
```

After automation Remediation
```bash
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*",
    "Condition" : {
      "ArnNotEquals" : {
        "aws:PrincipalArn" : [ "arn:aws:iam::454898608431:role/mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I", "arn:aws:iam::454898608431:role/LambdaRDSTestRole" ]
      }
    }
  }, {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : [ "secretsmanager:TagResource", "secretsmanager:UntagResource" ],
    "Resource" : "*"
  } ]
}
```

```bash
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Deny",
    "Principal" : {
      "AWS" : "*"
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*",
    "Condition" : {
      "ArnNotEquals" : {
        "aws:PrincipalArn" : [
          "arn:aws:iam::569651145632:role/mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I","arn:aws:iam::569651145632:role/RDSLambdaCFNInitRole",
          "arn:aws:iam::569651145632:role/LambdaRDSTestRole",
          "arn:aws:iam::569651145632:user/tu-dev" ]
      }
    }
  } ]
}


{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Event": "${aws:PrincipalTag/Event}",
                    "aws:ResourceTag/Workshop": "${aws:PrincipalTag/Workshop}"
                }
            },
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

## 

DemoWorkshopSecret
## Enable AWS Configure rules
- secretsmanager-workshop-rotation-enabled-check - secretsmanager-rotation-enabled-check
- secretsmanager-workshop-scheduled-rotation-success-check - secretsmanager-scheduled-rotation-success-check
- secretsmanager-workshop-using-cmk - secretsmanager-using-cmk
- secretsmanager-workshop-secret-periodic-rotation - secretsmanager-secret-periodic-rotation

Event Bridge rule for 

```bash
    {
      "source": [
        "aws.secretsmanager"
      ],
      "detail-type": [
        "AWS API Call via CloudTrail"
      ],
      "detail": {
        "eventSource": [
          "secretsmanager.amazonaws.com"
        ],
        "eventName": [
          "DeleteResourcePolicy"
        ]
      }
    }
```

```bash
aws configservice delete-config-rule --config-rule-name
export CONFIG_RULE=$(aws configservice describe-config-rules --query 'ConfigRules[*].ConfigRuleName' --output text --profile tu-dev)
for rule in $CONFIG_RULE; do aws configservice delete-config-rule --config-rule-name $rule --profile tu-dev; done;

aws secretsmanager get-secret-value --secret-id DemoWorkshopSecret --profile tu-dev

aws secretsmanager get-secret-value --secret-id DemoWorkshopSecret  --profile tu-dev

mysql -u demouser -h demordsdbinstance.cniyl16rlvzp.us-west-2.rds.amazonaws.com -D DemoRDSDB -p45z9FEv7k2ZO91BXMdQq -e 'select * from DemoTable'
```
