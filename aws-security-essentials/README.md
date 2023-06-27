# AWS Security Essential

S3 Bucket Policies

When a user that have the permission to assume the bucket assumes it. They are able to perform the specified action. This is despite that IAM does not specify or grant any permission. (This is resource based policy/permission)


Allow user to access bucket only when assuming the `BucketsRole` role.

```bash
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "S3Write",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::783152459493:role/BucketsRole"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::bravo-bucket-ap-southeast-2-766142334/*"
        },
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::783152459493:role/BucketsRole"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::bravo-bucket-ap-southeast-2-766142334"
        }
    ]
}
```

Allow  access bucket when assuming the `BucketsRole` on the following condition

- multifactor auth
- SourceIp
- Date and time boundaries

```bash
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ListBucketWithConditions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::783152459493:role/BucketsRole"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::charlie-bucket-ap-southeast-2-766142334",
            "Condition": {
                "StringEquals": {
                    "aws:MultiFactorAuthPresent": "true"
                },
                "NotIpAddress": {
                    "aws:SourceIp": "54.240.143.0"
                },
                "DateGreaterThan": {
                    "aws:CurrentTime": "2020-12-02T00:00:00Z"
                },
                "DateLessThan": {
                    "aws:CurrentTime": "2020-12-31T23:59:59Z"
                }
            }
        }
    ]
}
```


Policy for DevelopsGroup

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:CreateBucket",
                "s3:PutBucketOwnershipControls",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:PutAccountPublicAccessBlock",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutEncryptionConfiguration"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "AllowS3Actions"
        },
        {
            "Action": [
                "iam:GetGroup",
                "iam:GetGroupPolicy"
            ],
            "Resource": "arn:aws:iam::*:group/DevelopersGroup",
            "Effect": "Allow",
            "Sid": "AllowIamGroupReadActions"
        },
        {
            "Action": [
                "iam:GetUser",
                "iam:GetUserPolicy"
            ],
            "Resource": "arn:aws:iam::*:user/user-1",
            "Effect": "Allow",
            "Sid": "AllowIamUserReadActions"
        },
        {
            "Action": [
                "iam:GetRole",
                "iam:GetRolePolicy"
            ],
            "Resource": "arn:aws:iam::*:role/BucketsRole",
            "Effect": "Allow",
            "Sid": "AllowIamRoleReadActions"
        },
        {
            "Action": [
                "iam:Describe*",
                "iam:List*"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "AllowIamListDescribeActions"
        },
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::*:role/BucketsRole",
            "Effect": "Allow",
            "Sid": "AllowAssumeBucketsRole"
        }
    ]
}
```

Notice the policy allows the group to be able to assume the `BucketsRole` Policy


BucketsRole

Trust Relationship

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::783152459493:user/user-1"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

```

The Following are the policy in the `BucketsRole`

GetBucketPolicy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetBucketPolicy"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

ListAllBucketsPolicy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

S3BucketLockdown

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::alpha-bucket-ap-southeast-2-766142334",
                "arn:aws:s3:::alpha-bucket-ap-southeast-2-766142334/*"
            ],
            "Effect": "Allow"
        }
    ]
}
```
