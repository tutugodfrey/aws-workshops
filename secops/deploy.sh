#! /bin/bash

if [ -z AWS_PROFILE ]; then
  export AWS_PROFILE=tgodfrey
fi

aws sts get-caller-identity

aws cloudformation deploy --stack-name secops --template-file resource.yaml --profile tgodfrey --region us-east-1 --capabilities CAPABILITY_NAMED_IAM