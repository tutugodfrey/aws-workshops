# AWS Storage Immersion Day

[user1]
aws_access_key_id = AKIAXIBDD2N6WYVC42GD
aws_secret_access_key = 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
[user2]
aws_access_key_id = AKIAXIBDD2N6ZCSUHN52
aws_secret_access_key = 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



```bash
{
"Statement": [
{
   "Action": "s3:*",
   "Effect": "Deny",
   "Principal": "*",
   "Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
   "Condition": {
       "Bool": {
        "aws:SecureTransport": false
        }
    }
    }
  ]
}


{
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        }
    ]
}

{
    "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
              "s3:PutObject",
              "s3:PutObjectAcl"
          ],
          "Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
          "Condition": {
              "StringEquals": {
                  "s3:x-amz-acl": "private"
              }
          }
        }
    ]
}




{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
			"Condition": {
				"Bool": {
					"aws:SecureTransport": "false"
				}
			}
		},
		{
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
			"Condition": {
				"StringNotEquals": {
					"s3:x-amz-server-side-encryption": "AES256"
				}
			}
		},
		{
			"Effect": "Deny",
			"Principal": "*",
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl"
			],
			"Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": "private"
				}
			}
		},
    {
        "Effect": "Deny",
        "Principal": "*",
        "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl"
        ],
        "Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
        "Condition": {
            "StringEquals": {
                "s3:x-amz-acl": [
                    "public-read",
                    "public-read-write",
                    "authenticated-read"
                ]
            }
          }
        }
	]
}




{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": "*",
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl"
			],
			"Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": "private"
				}
			}
		},
		{
			"Effect": "Deny",
			"Principal": "*",
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl"
			],
			"Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-acl": [
						"public-read",
						"public-read-write",
						"authenticated-read"
					]
				}
			}
		}
	]
}



{
    "Statement": [
        {
            "Action": "s3:*",
            "Effect": "Deny",
            "Resource": "arn:aws:s3:::sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541/*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpce": "vpce-0d76c48f7160cb783"
                }
            },
            "Principal": "*"
        }
    ]
}
```

```bash
echo export bucket=sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541 >> ~/.bashrc

export bucket=sid-security-83f9b480-0e95-11ee-8fd4-0691d38bd541

aws s3api head-object --key app1/file1 --endpoint-url http://s3.amazonaws.com --profile user1 --bucket ${bucket}

aws s3api head-object --key app1/file1 --endpoint-url https://s3.amazonaws.com --profile user1 --bucket ${bucket}

aws s3api put-object --key text01 --body textfile --profile user1 --bucket ${bucket}

aws s3api put-object --key text01 --body textfile --server-side-encryption AES256 --profile user1 --bucket ${bucket}  

```

vpc endpoint id: vpce-0d76c48f7160cb783



```bash
aws configure set default.s3.max_concurrent_requests 1

aws configure set default.s3.multipart_threshold 64MB

aws configure set default.s3.multipart_chunksize 16MB


dd if=/dev/urandom of=5GB.file bs=1 count=0 seek=5G


time aws s3 cp 5GB.file s3://${bucket}/upload1.test

aws configure set default.s3.max_concurrent_requests 2

time aws s3 cp 5GB.file s3://${bucket}/upload1.test2

aws configure set default.s3.max_concurrent_requests 10

time aws s3 cp 5GB.file s3://${bucket}/upload1.test2

aws configure set default.s3.max_concurrent_requests 20

time aws s3 cp 5GB.file s3://${bucket}/upload1.test3

dd if=/dev/urandom of=1GB.file bs=1 count=0 seek=1G

time seq 1 5 | parallel --will-cite -j 5 aws s3 cp 1G.file s3://${bucket}/parallel/object{}.test

time seq 1 5 | parallel --will-cite -j 5 aws s3 cp 1GB.file s3://${bucket}/parallel/object{}.test


time (aws s3 cp s3://$bucket/upload1.test 5GB.file; aws s3 cp 5GB.file s3://$bucket/copy/5GB.file)  

time aws s3api copy-object --copy-source $bucket/upload1.test --bucket $bucket --key copy/5GB-2.file


```


DataSync Agent Activation Key: MCI18-D99Q2-F3F0D-2UL15-1P76T
Host IP: 54.185.38.58
Agent ID: arn:aws:datasync:us-east-1:498289857405:agent/agent-0134c4c028cbb77ea
arn:aws:datasync:us-east-1:498289857405:agent/agent-0134c4c028cbb77ea

arn:aws:datasync:us-east-1:498289857405:agent/agent-0134c4c028cbb77ea

sid-datasync-73838630-0e86-11ee-8790-12c83cad7f1d


Backup admin: volumeID: vol-08503c4ef4aacf892
Web Server Admin: vol-01a93958389deeda4	/dev/xvda 8
Web Server Admin: vol-02c65153b0087c9aa	/dev/sdf	1