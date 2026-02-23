# S3 Bucket Example

This example demonstrates how to use the S3 and S3-with-KMS modules.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

> **Warning**: This example creates real AWS resources. Ensure you have the necessary IAM permissions and be aware of associated costs.

## What is created

1. A simple S3 bucket with AES256 encryption and versioning
2. An S3 bucket with a dedicated KMS Customer Managed Key using the composite module
