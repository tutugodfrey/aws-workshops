# Data Discovery Activation Day

Workshop Guide

[Data Discovery and Classification with Amazon Macie](https://catalog.workshops.aws/data-discovery/en-US/investigate)

[Using managed data identifiers in Amazon Macie](https://docs.aws.amazon.com/macie/latest/user/managed-data-identifiers.html)

EventBridge Rule for Amazon Macie that target events based on Custom Identifiers

```bash
{
  "source": [
      "aws.macie"
  ],
  "detail": {
      "type": [
      "SensitiveData:S3Object/CustomIdentifier"
      ]
  }
}
```
