#! /bin/bash

if [ -z $AWS_PROFILE ]; then
  export AWS_PROFILE=tu-dev
fi

aws cloudformation deploy --stack-name security-governance-lab-1-service-catalog --template-file lab-resources.yaml --capabilities CAPABILITY_NAMED_IAM
