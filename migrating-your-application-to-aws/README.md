# Migrating Your Application To AWS

[AWS Partner: Migrating your Application to AWS](https://catalog.us-east-1.prod.workshops.aws/workshops/892d6da4-dec8-4d61-bcf5-5d9bcf6cef1e/en-US)


[Event Login](https://dashboard.eventengine.run/login)
Event Hash: 4e42-188390e8e4-13

Connect to aurora mysql

```bash
mysql -u admin -h tsgallery-dbcluster.cluster-cu2tya59aoo8.us-east-1.rds.amazonaws.com -pCXj2slOPTl9nwwSbsDyI
```

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticbeanstalk:CreateApplication",
                "elasticbeanstalk:DeleteApplication",
                "elasticbeanstalk:ListPlatformBranches"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

## Install eb cli on ec2

```bash
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
export PATH=~/.local/bin:$PATH
pip install awsebcli --upgrade --user
```

Sample ElasticBeanstalk Config

```bash
cat .elasticbeanstalk/config.yml 
branch-defaults:
  master:
    environment: Tsgallerybeanstalk-env-1
    group_suffix: null
global:
  application_name: TSGalleryBeanstalk
  branch: null
  default_ec2_keyname: null
  default_platform: Node.js 18 running on 64bit Amazon Linux 2
  default_region: us-east-1
  include_git_submodules: true
  instance_profile: null
  platform_name: null
  platform_version: null
  profile: ebcli
  repository: null
  sc: git
  workspace_type: Application
```

Set a profile for eb to use. This profile should have permission to create and manage elasticBeanstalk applications

You might have issues if the profile is not the same profile that create beanstalk environment 

```bash
aws configure set profile.ebcli.region us-east-1
aws configure set profile.ebcli.aws_access_key_id ASIA...
aws configure set profile.ebcli.aws_secret_access_key Es2X+8w...........
aws configure set profile.ebcli.aws_session_token IQoJb3JpZ2luX2VjEGc..............

eb list  # After configuring the ebcli profile that corresponds with the use that created the environment, this works even without specifying --profile. With no profile configure error occur
eb list --profile ebcli     # List eb environments
```

# Output

Tsgallerybeanstalk-env

```bash
git add .
git commit -m "Initial Commit"
eb init --profile ebcli
eb use Tsgallerybeanstalk-env-1  --profile ebcli
```

Deploy to elasticbeanstalk environment 
```bash

eb deploy --staged
```
```bash
eb init TSGalleryBeanstalk --profile ebcli   # ran with already created application TSGalleryBeanstalk, eb was able to import the environment, platform for the application
```

```bash
branch-defaults:
  master:
    environment: Tsgallerybeanstalk-env
environment-defaults:
  Tsgallerybeanstalk-env:
    branch: null
    repository: null
global:
  application_name: TSGalleryBeanstalk
  default_ec2_keyname: null
  default_platform: Node.js 18 running on 64bit Amazon Linux 2
  default_region: us-east-1
  include_git_submodules: true
  instance_profile: null
  platform_name: null
  platform_version: null
  profile: ebcli
  sc: git
  workspace_type: Application
```


Deploy an eb zip file to elasticbeanstalk

Start with an empty directory containing only the zip file to deploy, run the `eb init` or `eb init --profile ebcli` command

```bash
[root@ip-10-11-0-165 myapp]# ls
ts_gallery.zip
```

```bash
eb init
```

Will generate the eb `.elasticbeanstalk/config.yml` file

Add the deploy step to the file specifying the path to the zip file

```bash
deploy:
  artifact: ts_gallery.zip
```

The final content of the file is as shown below

`cat .elasticbeanstalk/config.yml`

```bash
branch-defaults:
  default:
    environment: Nodeapp-env
deploy:
  artifact: ts_gallery.zip
global:
  application_name: nodeapp
  branch: null
  default_ec2_keyname: null
  default_platform: Node.js 18 running on 64bit Amazon Linux 2
  default_region: us-east-1
  include_git_submodules: true
  instance_profile: null
  platform_name: null
  platform_version: null
  profile: ebcli
  repository: null
  sc: null
  workspace_type: Application
```

deploy 

```bash
eb deploy --staged
```

There is a difference when you use `eb init` with and without flags. Note the output we get by specifying the app name and profile flag below

```bash
eb init nodeapp --profile ebcli
```

```bash
branch-defaults:
  default:
    environment: Nodeapp-env
environment-defaults:
  Nodeapp-env:
    branch: null
    repository: null
global:
  application_name: nodeapp
  default_ec2_keyname: null
  default_platform: Node.js 18 running on 64bit Amazon Linux 2
  default_region: us-east-1
  include_git_submodules: true
  instance_profile: null
  platform_name: null
  platform_version: null
  profile: ebcli
  sc: null
  workspace_type: Application
```