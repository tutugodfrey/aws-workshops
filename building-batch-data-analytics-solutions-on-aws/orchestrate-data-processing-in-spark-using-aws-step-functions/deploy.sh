#! /bin/bash

if [ -z $AWS_PROFILE ]; then
  export AWS_PROFILE=tu-dev
fi

aws cloudformation deploy --stack-name emr-data-pipeline --template-file lab-resources.yaml --capabilities CAPABILITY_NAMED_IAM