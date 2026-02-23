# AWS Terraform Modules

A collection of reusable, best-practice AWS Terraform modules organized for scalability and maintainability.

## Repository Structure

```
aws/
└── terraform/
    ├── service/          # Atomic, single-service modules
    │   ├── s3/
    │   ├── ec2/
    │   ├── kms/
    │   ├── sns/
    │   ├── sqs/
    │   ├── rds/
    │   ├── dynamo_db/
    │   ├── document_db/
    │   └── api_gateway/
    ├── composite/        # Modules combining multiple atomic modules
    │   ├── s3_with_kms/
    │   ├── rds_with_kms/
    │   └── sqs_with_sns/
    └── examples/         # Example configurations
        ├── s3_bucket/
        └── messaging/
```

## Atomic Modules (`aws/terraform/service/`)

| Module | Description |
|--------|-------------|
| [s3](aws/terraform/service/s3/README.md) | Secure S3 bucket with encryption, versioning, and public access block |
| [ec2](aws/terraform/service/ec2/README.md) | EC2 instance with IMDSv2, encrypted EBS, and detailed monitoring |
| [kms](aws/terraform/service/kms/README.md) | KMS Customer Managed Key with automatic rotation |
| [sns](aws/terraform/service/sns/README.md) | SNS topic with KMS encryption and secure topic policy |
| [sqs](aws/terraform/service/sqs/README.md) | SQS queue with KMS encryption, DLQ, and long polling |
| [rds](aws/terraform/service/rds/README.md) | RDS instance with encryption, Multi-AZ, and automated backups |
| [dynamo_db](aws/terraform/service/dynamo_db/README.md) | DynamoDB table with encryption and point-in-time recovery |
| [document_db](aws/terraform/service/document_db/README.md) | DocumentDB cluster with encryption and automated backups |
| [api_gateway](aws/terraform/service/api_gateway/README.md) | API Gateway REST API with logging, tracing, and throttling |

## Composite Modules (`aws/terraform/composite/`)

| Module | Description |
|--------|-------------|
| [s3_with_kms](aws/terraform/composite/s3_with_kms/README.md) | S3 bucket with a dedicated KMS CMK |
| [rds_with_kms](aws/terraform/composite/rds_with_kms/README.md) | RDS instance with a dedicated KMS CMK |
| [sqs_with_sns](aws/terraform/composite/sqs_with_sns/README.md) | SNS topic with SQS queue subscription (fan-out pattern) |

## AWS Best Practices

All modules implement AWS security and operational best practices:

- **Encryption at Rest**: KMS encryption enabled by default on all data services
- **Encryption in Transit**: TLS enforced where applicable
- **Least Privilege**: Secure default IAM policies
- **No Public Access**: S3 public access blocked by default, RDS not publicly accessible
- **High Availability**: Multi-AZ enabled by default for RDS and DocumentDB
- **Monitoring & Observability**: CloudWatch metrics, X-Ray tracing for API Gateway
- **IMDSv2 Enforced**: EC2 instances use Instance Metadata Service v2
- **Deletion Protection**: Databases have deletion protection enabled by default

## Terraform Best Practices

- Module versioning with `versions.tf`
- Variable validation where applicable
- Sensitive variables marked as `sensitive = true`
- Consistent output naming
- Comprehensive README.md documentation per module

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0.0

## Getting Started

1. Choose a module from `aws/terraform/service/` or `aws/terraform/composite/`
2. Check the module's `README.md` for usage instructions
3. See `aws/terraform/examples/` for working examples