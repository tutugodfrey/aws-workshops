# SPDX-License-Identifier: MIT-0
import boto3
import json
from botocore.exceptions import ClientError

def handler(event, context):
     ASMClient = boto3.client('secretsmanager')
     IAMClient = boto3.client('iam')
     secretForWorkshop = "arn:aws:secretsmanager:us-east-1:454898608431:secret:DemoWorkshopSecret-DjM1Nn"

     try:
          if(event["detail"]["errorCode"] == 'AccessDenied'):
               pass
     except:
          retrievedsecret = event["detail"]["requestParameters"]["secretId"]
          if(retrievedsecret == secretForWorkshop):
            if('Role' in event["detail"]["userIdentity"]["type"]):
                 SessionRoleName=event['detail']['userIdentity']['sessionContext']["sessionIssuer"]['userName']
                 responseIAM = IAMClient.attach_role_policy(PolicyArn="arn:aws:iam::454898608431:policy/DenyUpdateSecretPolicy",RoleName=SessionRoleName,)
            else:
                 SessionUserName=event['detail']['userIdentity']['userName']
                 responseIAM = IAMClient.attach_user_policy(PolicyArn="arn:aws:iam::454898608431:policy/DenyUpdateSecretPolicy",UserName=SessionUserName,)
     
            PutSecretResourcePolicy = ASMClient.put_resource_policy(SecretId=retrievedsecret,ResourcePolicy='{ "Version" : "2012-10-17", "Statement" : [ { "Effect" : "Deny", "Principal" : { "AWS" : "*" }, "Action" : [ "secretsmanager:GetSecretValue" ], "Resource" : "*", "Condition" : { "ArnNotEquals" : { "aws:PrincipalArn" : [ "arn:aws:iam::454898608431:role/mod-ef616fd71d094108-Secr-SecretsManagerRDSMySQLRo-1TX9M82N6IO5I", "arn:aws:iam::454898608431:role/LambdaRDSTestRole"  ] } } },{ "Effect" : "Deny", "Principal" : { "AWS" : "*" }, "Action" :  [ "secretsmanager:TagResource", "secretsmanager:UntagResource" ], "Resource" : "*" }  ] }')
            responseASM = ASMClient.rotate_secret(SecretId=retrievedsecret,)
