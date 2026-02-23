# Messaging Example

This example demonstrates how to use the SNS, SQS, and SQS-with-SNS composite modules.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

> **Warning**: This example creates real AWS resources. Ensure you have the necessary IAM permissions and be aware of associated costs.

## What is created

1. An SNS topic with an SQS queue subscription using the composite module (fan-out pattern)
2. A standalone SQS queue with DLQ
