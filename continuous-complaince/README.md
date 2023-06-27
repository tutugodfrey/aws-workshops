# Continuous Compliance
[Writing AWS CloudFormation Guard rules](https://docs.aws.amazon.com/cfn-guard/latest/ug/writing-rules.html)

[Conformance Pack Sample Templates](https://docs.aws.amazon.com/config/latest/developerguide/conformancepack-sample-templates.html)

[How to Deploy AWS Config Conformance Packs Using Terraform](https://aws.amazon.com/blogs/mt/how-to-deploy-aws-config-conformance-packs-using-terraform/)

[Deploy AWS Config Rules and Conformance Packs using a delegated admin](https://aws.amazon.com/blogs/mt/deploy-aws-config-rules-and-conformance-packs-using-a-delegated-admin/)

Config > Advance Query 

```bash
SELECT
  *
WHERE
  resourceType = 'AWS::EC2::Subnet'
```

Custom Guard Rule

```bash
rule check_bucketversioning {
     supplementaryConfiguration.BucketVersioningConfiguration.status == "Enabled" <<
     result: NON_COMPLIANT
     message: S3 Bucket Versioning is NOT enabled.
     >>
}
```
