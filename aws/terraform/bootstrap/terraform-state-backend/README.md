# Terraform State Backend Bootstrap

This directory contains the bootstrap configuration for setting up your Terraform remote state infrastructure with enterprise-grade security and disaster recovery capabilities.

## Architecture

This bootstrap configuration **uses the same reusable service modules** that you use throughout your infrastructure, ensuring consistency and best practices. It composes the following modules:

- `../../service/kms` - For encryption key management
- `../../service/s3` - For state file storage
- `../../service/dynamo_db` - For state locking

Additional features for production environments:
- **IAM Policies** - Fine-grained access control
- **CloudTrail** - Comprehensive audit logging
- **S3 Replication** - Cross-region disaster recovery

This approach ensures:
- ✅ Consistent configuration across all your infrastructure
- ✅ DRY (Don't Repeat Yourself) - reuse tested modules
- ✅ Single source of truth for resource configuration
- ✅ Easy to maintain and update
- ✅ Enterprise-ready security and compliance

## What This Creates

This Terraform configuration creates the following resources needed for secure remote state management:

### Core Infrastructure

1. **S3 Bucket** (via `service/s3` module)
   - Versioning enabled
   - KMS encryption
   - Public access blocked
   - Lifecycle policies for old versions
   - Bucket policy enforcing encryption and secure transport

2. **KMS Key** (via `service/kms` module)
   - Automatic key rotation enabled
   - Used for both S3 and DynamoDB encryption

3. **DynamoDB Table** (via `service/dynamo_db` module)
   - On-demand billing mode
   - Point-in-time recovery enabled
   - Encrypted with KMS

### Security & Compliance Features

4. **IAM Policies** (optional, enabled by default)
   - Admin policy for full state access (CI/CD)
   - Read-only policy for developers
   - Automatic attachment to specified roles
   - Least privilege access control

5. **CloudTrail Logging** (optional)
   - Separate S3 bucket for audit logs
   - Tracks all state file access
   - Logs DynamoDB lock operations
   - Log file validation enabled
   - Compliance-ready audit trail

6. **Cross-Region Replication** (optional)
   - Backup S3 bucket in different region
   - Separate KMS key for replica
   - Automatic replication within 15 minutes
   - Replication Time Control (RTC) enabled
   - Business continuity / disaster recovery

## Why Use This Approach?

**✅ Benefits:**
- **Infrastructure as Code**: Your state backend is versioned and reproducible
- **Reusable Modules**: Uses the same tested modules as your main infrastructure
- **Security**: Enforces encryption, versioning, and secure access
- **Compliance Ready**: CloudTrail logging for SOC 2, ISO 27001, HIPAA
- **Disaster Recovery**: Optional cross-region replication
- **Access Control**: IAM policies with role-based access
- **Cost Effective**: Uses best practices (lifecycle policies, on-demand billing)
- **Auditable**: Changes are tracked in version control
- **Repeatable**: Can create identical setups across environments

**❌ Avoid Manual Setup Because:**
- Manual configurations are error-prone
- No audit trail of what was configured
- Hard to replicate across environments
- Easier to miss security best practices
- No easy way to tear down and recreate

## Bootstrap Process

### Step 1: Initial Setup (Run Once per Environment)

```bash
cd bootstrap/terraform-state-backend

# Copy and configure your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your account ID and preferences

# Initialize Terraform (uses local state for bootstrap)
terraform init

# Review what will be created
terraform plan

# Create the state backend infrastructure
terraform apply
```

At this point, your state is stored **locally** in `terraform.tfstate`.

### Step 2: Migrate to Remote State (Optional but Recommended)

After creating the backend, you can migrate this bootstrap configuration to use the remote state it just created:

1. Create a `backend.tf` file:

```hcl
terraform {
  backend "s3" {
    bucket         = "469240347599-terraform-states-prod"
    key            = "bootstrap/terraform-state-backend.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"
  }
}
```

2. Migrate the state:

```bash
terraform init -migrate-state
```

3. Verify the migration:

```bash
terraform plan
```

### Step 3: Use in Other Projects

After creating the backend, use these outputs in your other Terraform projects:

```bash
# Get the backend configuration
terraform output backend_config
```

Then in your other projects (like the ECR example), configure the backend:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "469240347599-terraform-states-prod"
    key            = "ecr/terraform.tfstate"  # Unique key per project
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"
  }
}
```

Or use partial configuration:

```bash
# backend-config.hcl
bucket         = "469240347599-terraform-states-prod"
region         = "eu-west-1"
dynamodb_table = "terraform-state-lock-prod"
encrypt        = true
```

```bash
terraform init -backend-config=backend-config.hcl
```

## Multi-Environment Setup

For multiple environments (dev, staging, prod), you can either:

### Option 1: Separate State Backends per Environment

Run this bootstrap for each environment with different tfvars:

```bash
# Production
terraform apply -var-file=prod.tfvars

# Staging
terraform apply -var-file=staging.tfvars
```

### Option 2: Single State Backend, Multiple State Keys

Create one state backend and use different keys per environment:

```hcl
# Production
terraform {
  backend "s3" {
    key = "prod/ecr/terraform.tfstate"
  }
}

# Staging
terraform {
  backend "s3" {
    key = "staging/ecr/terraform.tfstate"
  }
}
```

## Security Considerations

This configuration implements several security best practices:

- ✅ **Encryption at Rest**: All data encrypted with KMS
- ✅ **Encryption in Transit**: Enforced via bucket policy
- ✅ **Versioning**: Protects against accidental deletions
- ✅ **Access Control**: Public access blocked
- ✅ **State Locking**: Prevents concurrent modifications
- ✅ **Audit Trail**: CloudTrail captures all API calls
- ✅ **Key Rotation**: KMS key rotation enabled
- ✅ **Point-in-Time Recovery**: DynamoDB backup enabled

## Cost Optimization

- **S3**: Pay only for storage used (minimal for state files)
- **DynamoDB**: PAY_PER_REQUEST mode (only charged for actual usage)
- **KMS**: ~$1/month per key + minimal per-request charges
- **Lifecycle Policies**: Automatically remove old versions after 90 days

Estimated monthly cost: **$2-5** depending on usage

## Variables

| Name | Description | Default | Required |
|------|-------------|---------|----------|
| account_id | AWS account ID | - | yes |
| region | AWS region | us-east-1 | no |
| environment | Environment name | prod | no |
| kms_deletion_window_in_days | KMS key deletion window | 30 | no |
| noncurrent_version_expiration_days | Days to keep old state versions | 90 | no |
| enable_logging | Enable S3 access logging | false | no |
| logging_bucket | Bucket for access logs | "" | no |
| tags | Additional tags | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_name | Name of the S3 bucket |
| dynamodb_table_name | Name of the DynamoDB table |
| kms_key_arn | ARN of the KMS key |
| backend_config | Complete backend configuration |

## Troubleshooting

### Error: Bucket name already exists

S3 bucket names are globally unique. Change the `account_id` or `environment` variables.

### Error: Access Denied

Ensure your AWS credentials have sufficient permissions to create S3, DynamoDB, and KMS resources.

### State file is too large

Implement state splitting by using separate state files for different resources:
- One for networking
- One for compute
- One for data stores
- etc.

## Backup and Disaster Recovery

1. **S3 Versioning**: Enabled by default, keeps all versions
2. **Cross-Region Replication** (optional): Add to main.tf if needed
3. **DynamoDB PITR**: Enabled by default, allows point-in-time recovery
4. **Manual Backup**: Store the bootstrap state file securely (encrypted)

## Destroying the Backend

⚠️ **WARNING**: This will delete all your Terraform state files!

Before destroying:

1. Migrate all projects to local state or another backend
2. Ensure all state files are backed up
3. Empty the S3 bucket versions

```bash
# List all versions
aws s3api list-object-versions --bucket <bucket-name>

# Delete all versions and delete markers (be careful!)
aws s3api delete-objects --bucket <bucket-name> --delete "$(aws s3api list-object-versions --bucket <bucket-name> --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

# Destroy the infrastructure
terraform destroy
```

## References

- [Terraform S3 Backend Documentation](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [Terraform State Best Practices](https://www.terraform.io/docs/language/state/index.html)

