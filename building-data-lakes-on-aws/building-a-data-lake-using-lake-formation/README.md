# Build a Data Lake Using AWS Lake Formation

### Resource

[AWS Glue PySpark transforms reference](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-python-transforms.html)

- RoleName: LakeFormationServiceRole

- PolicyName: LakeFormationPol

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::databucket-us-east-1-9417692367538281/data/*",
                "arn:aws:s3:::databucket-us-east-1-9417692367538281/results/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::databucket-us-east-1-9417692367538281"
            ],
            "Effect": "Allow"
        }
    ]
}
```

- Create role: AdminGlueServiceRole
- AWS Managed Policy: AWSGlueServiceRole
- Role PolicyName: dataLakePol

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "lakeformation:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Antena Queries

```bash
SELECT * FROM "movies-db"."data" limit 10;
SELECT COUNT('genres_0') FROM "movies-db"."data" where genres_0='Action' LIMIT 10;
SELECT * FROM "movies-db"."movies_csv" limit 10;
SELECT * FROM "movies-db"."movies_parquet" limit 10;
```