# Container Security

Workshop Guide

[Container Security Workshop with Amazon EKS](https://catalog.us-east-1.prod.workshops.aws/workshops/440763fa-76b9-4fc7-817c-5964350ec1da/en-US)


Container image from CodeCommit

```bash
FROM public.ecr.aws/nginx/nginx:1.19.5
FROM public.ecr.aws/o0i8w5l9/security-activationday-repo:node
```

Create Role - devsecops-inspector-conta-ContainerScanResultsRole-GHUBYGGITYXE

Create function - eval-container-scan-results

Create EventBridge Rule - InspectorContainerScanStatus with lambda target - eval-container-scan-results

Create DynamoDB Table - ContainerImageApprovals 


Create Role - devsecops-inspector-contai-PipelineApprovalMsgRole-1ORG08FLBJ6PB
Create Lambda Function - process-build-approval-msg
Create SNS Topic - ContainerApprovalTopic
Subscript the Lambda process-build-approval-msg to the SNS Topic


Create a Role - kubescape-kubescapesecurityhubingestioniamrole-1A9TUPRC12Y9X

Create Lambda function - kubescape-kubescapesecurityhubingestion-3kMzTozqyfdS

Create S3 Bucket - kubescape-securityhub-us-west-2-569651145632

Add the S3 bucket as Trigger for the Lambda function


Run Kubescape

export PATH=$PATH:/home/ec2-user/.kubescape/bin

kubescape scan

