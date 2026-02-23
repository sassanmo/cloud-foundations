# Clound Foundations

A collection of reusable, best-practice Terraform modules (e.g. for AWS) organized for scalability and maintainability.

## Repository Structure

```
aws/
└── terraform/
    ├── service/
    │   ├── alb/
    │   ├── api_gateway/
    │   ├── athena/
    │   ├── aurora/
    │   ├── bedrock/
    │   ├── budgets/
    │   ├── cloudwatch_alarms/
    │   ├── cloudwatch_logs/
    │   ├── cognito/
    │   ├── document_db/
    │   ├── dynamo_db/
    │   ├── ec2/
    │   ├── ecr/
    │   ├── ecs/
    │   ├── ecs_task/
    │   ├── efs/
    │   ├── eks/
    │   ├── elasticache/
    │   ├── eventbridge/
    │   ├── glue/
    │   ├── iam_role/
    │   ├── kms/
    │   ├── lambda/
    │   ├── rds/
    │   ├── s3/
    │   ├── secrets_manager/
    │   ├── security_hub/
    │   ├── ses/
    │   ├── sns/
    │   ├── sqs/
    │   ├── ssm_parameter/
    │   ├── step_functions/
    │   └── vpc/
    ├── composite/
    │   ├── rds_with_kms/
    │   ├── s3_with_kms/
    │   ├── secrets_manager_with_kms/
    │   └── sqs_with_sns/
    └── examples/
        ├── messaging/
        └── s3_bucket/
```

## Atomic Modules (`aws/terraform/service/`)

### Compute & Containers
| Module | Description |
|--------|-------------|
| [lambda](aws/terraform/service/lambda/README.md) | Lambda functions with IAM roles, VPC support, and CloudWatch logs |
| [ecs](aws/terraform/service/ecs/README.md) | ECS clusters, task definitions, and services with Fargate/EC2 support |
| [ecs_task](aws/terraform/service/ecs_task/README.md) | ECS task definitions with container configurations |
| [ec2](aws/terraform/service/ec2/README.md) | EC2 instance with IMDSv2, encrypted EBS, and detailed monitoring |
| [eks](aws/terraform/service/eks/README.md) | EKS clusters with Kubernetes 1.32, addons, and control plane logging |

### Networking & Load Balancing
| Module | Description |
|--------|-------------|
| [alb](aws/terraform/service/alb/README.md) | Application Load Balancers with target groups, listeners, and routing rules |
| [vpc](aws/terraform/service/vpc/README.md) | VPC with subnets, route tables, NAT gateways, and flow logs |

### Messaging & Events
| Module | Description |
|--------|-------------|
| [eventbridge](aws/terraform/service/eventbridge/README.md) | EventBridge event buses, rules, targets, and archives |
| [sns](aws/terraform/service/sns/README.md) | SNS topic with KMS encryption and secure topic policy |
| [sqs](aws/terraform/service/sqs/README.md) | SQS queue with KMS encryption, DLQ, and long polling |
| [ses](aws/terraform/service/ses/README.md) | SES email identities, configuration sets, and sending authorization |

### Storage & Databases
| Module | Description |
|--------|-------------|
| [s3](aws/terraform/service/s3/README.md) | Secure S3 bucket with encryption, versioning, and public access block |
| [rds](aws/terraform/service/rds/README.md) | RDS instance with encryption, Multi-AZ, and automated backups |
| [aurora](aws/terraform/service/aurora/README.md) | Aurora clusters (MySQL/PostgreSQL) with serverless v2 support |
| [dynamo_db](aws/terraform/service/dynamo_db/README.md) | DynamoDB table with encryption and point-in-time recovery |
| [document_db](aws/terraform/service/document_db/README.md) | DocumentDB cluster with encryption and automated backups |
| [elasticache](aws/terraform/service/elasticache/README.md) | ElastiCache Redis/Memcached clusters with encryption |
| [efs](aws/terraform/service/efs/README.md) | EFS file systems with encryption and lifecycle policies |
| [ecr](aws/terraform/service/ecr/README.md) | ECR repositories with image scanning and lifecycle policies |

### Security & Identity
| Module | Description |
|--------|-------------|
| [kms](aws/terraform/service/kms/README.md) | KMS Customer Managed Key with automatic rotation |
| [secrets_manager](aws/terraform/service/secrets_manager/README.md) | Secrets Manager for secure credential storage with rotation support |
| [iam_role](aws/terraform/service/iam_role/README.md) | IAM roles with managed policies, inline policies, and instance profiles |
| [cognito](aws/terraform/service/cognito/README.md) | Cognito user pools and identity pools for authentication |
| [security_hub](aws/terraform/service/security_hub/README.md) | Security Hub with CIS, AWS Foundational, PCI DSS, and NIST standards |

### Monitoring & Logging
| Module | Description |
|--------|-------------|
| [cloudwatch_logs](aws/terraform/service/cloudwatch_logs/README.md) | CloudWatch log groups, streams, metric filters, and query definitions |
| [cloudwatch_alarms](aws/terraform/service/cloudwatch_alarms/README.md) | CloudWatch alarms with SNS notifications and composite alarms |

### API & Integration
| Module | Description |
|--------|-------------|
| [api_gateway](aws/terraform/service/api_gateway/README.md) | API Gateway REST API with logging, tracing, and throttling |
| [step_functions](aws/terraform/service/step_functions/README.md) | Step Functions state machines for workflow orchestration |

### Analytics & Data Processing
| Module | Description |
|--------|-------------|
| [athena](aws/terraform/service/athena/README.md) | Athena workgroups and databases for SQL analytics |
| [glue](aws/terraform/service/glue/README.md) | Glue catalogs, databases, crawlers, and ETL jobs |

### AI & Machine Learning
| Module | Description |
|--------|-------------|
| [bedrock](aws/terraform/service/bedrock/README.md) | Bedrock agents, knowledge bases, and guardrails for generative AI |

### Cost Management & Configuration
| Module | Description |
|--------|-------------|
| [budgets](aws/terraform/service/budgets/README.md) | AWS Budgets for cost monitoring with email and SNS alerts |
| [ssm_parameter](aws/terraform/service/ssm_parameter/README.md) | SSM Parameter Store for configuration and secrets management |

## Composite Modules (`aws/terraform/composite/`)

| Module | Description |
|--------|-------------|
| [s3_with_kms](aws/terraform/composite/s3_with_kms/README.md) | S3 bucket with a dedicated KMS CMK |
| [rds_with_kms](aws/terraform/composite/rds_with_kms/README.md) | RDS instance with a dedicated KMS CMK |
| [secrets_manager_with_kms](aws/terraform/composite/secrets_manager_with_kms/README.md) | Secrets Manager secret with a dedicated KMS CMK |
| [sqs_with_sns](aws/terraform/composite/sqs_with_sns/README.md) | SNS topic with SQS queue subscription (fan-out pattern) |

## AWS Best Practices

All modules implement AWS security and operational best practices:

- **Encryption at Rest**: KMS encryption enabled by default on all data services
- **Encryption in Transit**: TLS enforced where applicable
- **Least Privilege**: Secure default IAM policies
- **No Public Access**: S3 public access blocked by default, RDS not publicly accessible
- **High Availability**: Multi-AZ enabled by default for RDS, Aurora, and DocumentDB
- **Monitoring & Observability**: CloudWatch metrics, logs, and X-Ray tracing where applicable
- **IMDSv2 Enforced**: EC2 instances use Instance Metadata Service v2
- **Deletion Protection**: Databases have deletion protection enabled by default
- **Container Insights**: ECS clusters have Container Insights enabled by default
- **Secret Rotation**: Secrets Manager supports automatic rotation with Lambda
- **Image Scanning**: ECR repositories scan images for vulnerabilities
- **Security Standards**: Security Hub enforces CIS, AWS Foundational, and compliance frameworks

## Terraform Best Practices

- Module versioning with `versions.tf`
- Variable validation where applicable
- Sensitive variables marked as `sensitive = true`
- Consistent output naming
- Comprehensive README.md documentation per module
- Consistent naming convention: `{project}-{environment}-{resource-suffix}`
- Tag support across all modules

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0 (>= 5.0 for Bedrock)

## Getting Started

1. Choose a module from `aws/terraform/service/` or `aws/terraform/composite/`
2. Check the module's `README.md` for usage instructions
3. See `aws/terraform/examples/` for working examples

### Example Usage

```hcl
module "lambda" {
  source = "./aws/terraform/service/lambda"

  project              = "myapp"
  environment          = "prod"
  function_name_suffix = "processor"
  
  handler = "index.handler"
  runtime = "nodejs18.x"
  filename = "lambda.zip"
  
  environment_variables = {
    LOG_LEVEL = "info"
  }
  
  tags = {
    Team      = "platform"
    ManagedBy = "terraform"
  }
}
```

## Module Highlights

### Recently Added Modules

- **Bedrock** - Generative AI with agents, knowledge bases (RAG), and content guardrails
- **Security Hub** - Multi-standard security compliance monitoring (CIS, PCI DSS, NIST)
- **ECR** - Container image registry with vulnerability scanning
- **Budgets** - Cost monitoring with forecasting and multi-threshold alerts
- **SSM Parameter** - Hierarchical configuration and secrets storage
- **IAM Role** - Complete IAM role management with policies and instance profiles
- **EKS** - Kubernetes 1.32 clusters with managed node groups and addons
- **Aurora** - Serverless v2 and provisioned Aurora clusters

### Comprehensive Coverage

The repository now includes **33 atomic service modules** covering:
- ✅ Compute (Lambda, ECS, EC2, EKS)
- ✅ Networking (VPC, ALB)
- ✅ Storage (S3, EFS, ECR)
- ✅ Databases (RDS, Aurora, DynamoDB, DocumentDB, ElastiCache)
- ✅ Security (KMS, Secrets Manager, IAM, Cognito, Security Hub)
- ✅ Messaging (SNS, SQS, EventBridge, SES)
- ✅ Analytics (Athena, Glue)
- ✅ AI/ML (Bedrock)
- ✅ Monitoring (CloudWatch Logs, CloudWatch Alarms)
- ✅ Integration (API Gateway, Step Functions)
- ✅ Cost Management (Budgets)
- ✅ Configuration (SSM Parameter Store)

## Contributing

When adding new modules:
1. Follow the established structure
2. Include comprehensive README with examples
3. Use consistent naming patterns
4. Add appropriate outputs
5. Include versions.tf with provider constraints
6. Update this README with the new module
7. Implement best practices (encryption, least privilege, etc.)

## License

See [LICENSE](LICENSE) file for details.
