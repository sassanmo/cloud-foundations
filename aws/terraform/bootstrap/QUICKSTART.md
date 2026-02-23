# Quick Start Guide: Terraform State Backend Setup

This guide walks you through setting up secure remote state for your Terraform projects.

## Step-by-Step Setup

### 1. Bootstrap Your State Backend (One Time)

```bash
# Navigate to bootstrap directory
cd aws/terraform/bootstrap/terraform-state-backend/

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**terraform.tfvars example:**
```hcl
account_id  = "469240347599"
region      = "eu-west-1"
environment = "prod"

tags = {
  Project    = "cloud-foundations"
  ManagedBy  = "Terraform"
}
```

```bash
# Initialize Terraform (uses local state for bootstrap)
terraform init

# Review the plan
terraform plan

# Create the infrastructure
terraform apply
```

**Save the outputs!**
```bash
terraform output
# You'll need:
# - s3_bucket_name
# - dynamodb_table_name
# - region
```

### 2. Configure Your Project to Use Remote State

Navigate to your project (e.g., ECR example):

```bash
cd ../../examples/ecr/
```

**Option A: Using backend-config file (Recommended)**

```bash
# Copy the example
cp backend-config.hcl.example backend-config.hcl

# Edit with your bootstrap outputs
nano backend-config.hcl
```

**backend-config.hcl:**
```hcl
bucket         = "469240347599-terraform-states-prod"  # From bootstrap output
region         = "eu-west-1"
dynamodb_table = "terraform-state-lock-prod"           # From bootstrap output
encrypt        = true
```

**Uncomment the backend block in backend.tf:**
```hcl
terraform {
  backend "s3" {
    bucket         = "469240347599-terraform-states-prod"
    key            = "ecr/terraform.tfstate"  # Unique per project
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"
  }
}
```

**Initialize with backend:**
```bash
terraform init -backend-config=backend-config.hcl
```

**Option B: Direct configuration in backend.tf**

Just uncomment and edit the backend.tf file with your values, then:

```bash
terraform init
```

### 3. Use Terraform Normally

```bash
# Configure your project variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Plan and apply
terraform plan
terraform apply
```

## Multi-Environment Setup

### Option 1: Separate Backends per Environment

Create separate state backends:

```bash
# Production
cd bootstrap/terraform-state-backend/
terraform workspace new prod  # or use separate tfvars
terraform apply -var-file=prod.tfvars

# Staging
terraform workspace new staging
terraform apply -var-file=staging.tfvars
```

### Option 2: Single Backend, Different Keys

Use one backend with environment-specific keys:

**Production:**
```hcl
terraform {
  backend "s3" {
    key = "prod/ecr/terraform.tfstate"
    # ... other config
  }
}
```

**Staging:**
```hcl
terraform {
  backend "s3" {
    key = "staging/ecr/terraform.tfstate"
    # ... other config
  }
}
```

## Migration from Local to Remote State

If you already have local state:

```bash
# Configure backend in backend.tf
terraform init -migrate-state

# Confirm migration
# Type 'yes' when prompted

# Verify
terraform plan  # Should show no changes
```

## Best Practices

### 1. State File Organization

Organize your keys by environment and component:
```
prod/
  networking/terraform.tfstate
  compute/terraform.tfstate
  data/terraform.tfstate
staging/
  networking/terraform.tfstate
  compute/terraform.tfstate
dev/
  networking/terraform.tfstate
```

### 2. Access Control

Use IAM policies to restrict access:

```hcl
# Developers can read, only CI/CD can write
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT:role/TerraformCI"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::bucket-name/*",
        "arn:aws:s3:::bucket-name"
      ]
    }
  ]
}
```

### 3. Backup Strategy

- S3 versioning is enabled (automatic backups)
- Consider cross-region replication for DR
- Export important states manually:
  ```bash
  terraform state pull > backup-$(date +%Y%m%d).tfstate
  ```

### 4. State Locking

Always enable state locking (DynamoDB) to prevent concurrent modifications:
```bash
# If lock is stuck:
terraform force-unlock <LOCK_ID>
```

## Troubleshooting

### Error: Backend configuration changed

```bash
terraform init -reconfigure
```

### Error: Failed to acquire state lock

Someone else is running Terraform, or a previous run failed:

```bash
# Wait for the other person to finish, or:
terraform force-unlock <LOCK_ID>
```

### State file is too large

Split your infrastructure into multiple state files:
- Separate by layer (networking, compute, data)
- Separate by environment
- Use terraform workspaces

### Need to move resources between states

```bash
# Pull states
terraform state pull > old.tfstate

# In target directory
terraform state push old.tfstate

# Remove from source
terraform state rm <resource>
```

## Security Checklist

- [x] S3 bucket encryption enabled (KMS)
- [x] S3 versioning enabled
- [x] S3 public access blocked
- [x] DynamoDB encryption enabled
- [x] State locking enabled
- [x] Secure transport enforced (HTTPS only)
- [x] KMS key rotation enabled
- [x] Lifecycle policies for old versions
- [x] IAM policies restricting access (Admin & Read-Only)
- [x] CloudTrail logging enabled
- [x] Backup/replication configured (optional)

**All security features are now available!** Configure them in `terraform.tfvars`:

```hcl
# Enable IAM access control policies
create_iam_policies = true
terraform_admin_role_arns = [
  "arn:aws:iam::ACCOUNT:role/TerraformCICD"
]
terraform_read_only_role_arns = [
  "arn:aws:iam::ACCOUNT:role/Developers"
]

# Enable CloudTrail audit logging
enable_cloudtrail = true

# Enable cross-region replication for DR
enable_replication  = true
replication_region  = "us-west-2"
```

## Cost Estimate

**Monthly costs (approximate):**
- S3 storage: $0.01 - $1 (depends on state file sizes)
- DynamoDB: $0 - $2 (PAY_PER_REQUEST, minimal usage)
- KMS: $1 + $0.03 per 10,000 requests
- **Total: $2-5/month**

## Summary

1. ✅ Create state backend using bootstrap Terraform
2. ✅ Configure backend in your projects
3. ✅ Initialize with `terraform init`
4. ✅ Work normally with `plan` and `apply`
5. ✅ State is automatically stored remotely and locked
