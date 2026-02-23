# Advanced Security Features Guide

This guide explains the advanced security, compliance, and disaster recovery features available in the Terraform State Backend module.

## Table of Contents

1. [IAM Access Control](#iam-access-control)
2. [CloudTrail Audit Logging](#cloudtrail-audit-logging)
3. [Cross-Region Replication](#cross-region-replication)
4. [Complete Configuration Example](#complete-configuration-example)
5. [Compliance Mapping](#compliance-mapping)

---

## IAM Access Control

### Overview

The module creates two IAM policies for granular access control:

1. **TerraformStateAdmin** - Full access for automation (CI/CD, administrators)
2. **TerraformStateReadOnly** - Read-only access for developers and auditors

### Configuration

```hcl
create_iam_policies = true

# Full access roles (CI/CD pipelines, infrastructure admins)
terraform_admin_role_arns = [
  "arn:aws:iam::123456789012:role/GitHubActions-Terraform",
  "arn:aws:iam::123456789012:role/InfrastructureAdmin"
]

# Read-only roles (developers, auditors)
terraform_read_only_role_arns = [
  "arn:aws:iam::123456789012:role/DevelopersGroup",
  "arn:aws:iam::123456789012:role/SecurityAuditors"
]
```

### Admin Policy Permissions

The admin policy grants:

**S3 Permissions:**
- List bucket and get bucket properties
- Get, put, and delete objects
- Access object versions

**DynamoDB Permissions:**
- Get, put, and delete items (for state locking)
- Describe table

**KMS Permissions:**
- Encrypt and decrypt data
- Generate data keys
- Describe keys

### Read-Only Policy Permissions

The read-only policy grants:

**S3 Permissions:**
- List bucket and get bucket properties
- Get objects and object versions (no write/delete)

**DynamoDB Permissions:**
- Get items and describe table (no write/delete)

**KMS Permissions:**
- Decrypt data only (no encryption capabilities)

### Use Cases

**Admin Access:**
- CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins)
- Infrastructure administrators
- Terraform automation accounts

**Read-Only Access:**
- Developers viewing state for troubleshooting
- Security auditors reviewing infrastructure
- Compliance teams

### Manual Policy Attachment

If you don't specify role ARNs, you can manually attach policies:

```bash
# List policies
terraform output admin_policy_arn
terraform output readonly_policy_arn

# Attach to a role
aws iam attach-role-policy \
  --role-name MyRole \
  --policy-arn arn:aws:iam::ACCOUNT:policy/terraform/TerraformStateAdmin-prod
```

---

## CloudTrail Audit Logging

### Overview

CloudTrail provides a complete audit trail of all access to your Terraform state, tracking:
- Who accessed state files
- When they accessed them
- What operations were performed
- From which IP address
- Using which AWS credentials

### Configuration

```hcl
enable_cloudtrail = true

# Optional: specify custom CloudTrail bucket name
# cloudtrail_bucket_name = "my-central-audit-logs"
```

If you don't specify a bucket name, it auto-generates: `{account_id}-terraform-state-cloudtrail-{environment}`

### What Gets Logged

**S3 Data Events:**
- `GetObject` - State file reads
- `PutObject` - State file writes
- `DeleteObject` - State file deletions
- `GetObjectVersion` - Access to previous versions

**DynamoDB Events:**
- `GetItem` - Lock reads
- `PutItem` - Lock acquisitions
- `DeleteItem` - Lock releases

**Management Events:**
- Bucket policy changes
- Table configuration changes
- IAM policy modifications

### Log Format

CloudTrail logs are JSON format with detailed information:

```json
{
  "eventVersion": "1.08",
  "eventTime": "2024-03-05T10:15:30Z",
  "eventName": "GetObject",
  "userIdentity": {
    "type": "AssumedRole",
    "arn": "arn:aws:sts::123456789012:assumed-role/GitHubActions/session"
  },
  "sourceIPAddress": "54.123.45.67",
  "requestParameters": {
    "bucketName": "123456789012-terraform-states-prod",
    "key": "networking/vpc/terraform.tfstate"
  }
}
```

### Querying Logs

**Using AWS CLI:**
```bash
# Search for all state access in last 24 hours
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=terraform-states-prod \
  --start-time $(date -u -d '24 hours ago' +%s) \
  --max-results 50

# Find who accessed a specific state file
aws s3api select-object-content \
  --bucket CLOUDTRAIL-BUCKET \
  --key AWSLogs/ACCOUNT/CloudTrail/REGION/YYYY/MM/DD/file.json.gz \
  --expression "SELECT * FROM S3Object[*].Records[*] WHERE requestParameters.key = 'prod/vpc/terraform.tfstate'"
```

**Using Athena:**
1. Create CloudTrail table in Athena
2. Query with SQL:
```sql
SELECT
  eventtime,
  useridentity.principalid,
  eventname,
  requestparameters
FROM cloudtrail_logs
WHERE
  requestparameters LIKE '%terraform.tfstate%'
  AND eventtime > '2024-03-01'
ORDER BY eventtime DESC;
```

### Alerts and Monitoring

Set up CloudWatch alarms for suspicious activity:

```hcl
resource "aws_cloudwatch_metric_alarm" "unauthorized_state_access" {
  alarm_name          = "terraform-state-unauthorized-access"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAccess"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alert on unauthorized Terraform state access"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

### Compliance Benefits

CloudTrail logging helps meet requirements for:
- **SOC 2** - Access monitoring and audit trails
- **ISO 27001** - Information security management
- **HIPAA** - Access audit logs
- **PCI DSS** - Activity monitoring
- **GDPR** - Data access tracking

---

## Cross-Region Replication

### Overview

S3 replication creates a real-time backup of your Terraform state in a different AWS region, providing:
- Disaster recovery capability
- Protection against regional outages
- Geographic redundancy
- Compliance with data residency requirements

### Configuration

```hcl
enable_replication = true
replication_region = "us-west-2"  # Must be different from primary region
```

### What Gets Created

1. **Replica S3 Bucket** - In the replication region
2. **Replica KMS Key** - For encryption in the replication region
3. **IAM Replication Role** - Allows S3 to replicate objects
4. **Replication Configuration** - With S3 RTC enabled

### Replication Features

**Speed:**
- S3 Replication Time Control (RTC) enabled
- 99.99% of objects replicated within 15 minutes
- Most objects replicate in seconds

**What's Replicated:**
- All state files
- All object versions
- Object metadata
- Delete markers
- Object tags

**Encryption:**
- Objects encrypted with KMS in both regions
- Separate KMS keys for source and destination
- Keys encrypted in transit

### Recovery Procedures

**Regional Failure Scenario:**

If the primary region becomes unavailable:

1. **Update backend configuration** to use replica:
```hcl
terraform {
  backend "s3" {
    bucket         = "123456789012-terraform-states-prod-replica"
    region         = "us-west-2"  # Replication region
    key            = "my-project/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"  # Need to recreate
  }
}
```

2. **Recreate DynamoDB lock table** (if needed):
```bash
aws dynamodb create-table \
  --table-name terraform-state-lock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
```

3. **Re-initialize Terraform:**
```bash
terraform init -reconfigure
```

**Testing Failover:**

Regularly test your failover procedures:

```bash
# 1. Verify replication is working
aws s3api get-bucket-replication --bucket PRIMARY-BUCKET

# 2. Compare object counts
PRIMARY=$(aws s3 ls s3://PRIMARY-BUCKET/ --recursive | wc -l)
REPLICA=$(aws s3 ls s3://REPLICA-BUCKET/ --recursive --region REPLICA-REGION | wc -l)
echo "Primary: $PRIMARY, Replica: $REPLICA"

# 3. Test state access from replica
terraform init -backend-config="bucket=REPLICA-BUCKET" -backend-config="region=REPLICA-REGION"
terraform plan
```

### Replication Monitoring

**CloudWatch Metrics:**
- `ReplicationLatency` - Time to replicate objects
- `BytesPendingReplication` - Data waiting to replicate
- `OperationsPendingReplication` - Operations waiting

**Check replication status:**
```bash
# Get replication metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name ReplicationLatency \
  --dimensions Name=SourceBucket,Value=PRIMARY-BUCKET \
  --start-time 2024-03-05T00:00:00Z \
  --end-time 2024-03-05T23:59:59Z \
  --period 3600 \
  --statistics Average,Maximum
```

### Cost Considerations

**Additional costs for replication:**
- **Storage** - Duplicate storage in second region (~$0.023/GB/month in US regions)
- **Replication** - Data transfer between regions (~$0.02/GB)
- **KMS** - Additional KMS key ($1/month)
- **Requests** - PUT requests in destination region

**Example monthly cost:**
- 10GB of state files = $0.23 storage + $0.20 transfer + $1 KMS = ~$1.50/month
- 100GB of state files = $2.30 storage + $2.00 transfer + $1 KMS = ~$5.50/month

---

## Complete Configuration Example

### Production Environment with All Features

```hcl
# terraform.tfvars

# Basic Configuration
account_id  = "123456789012"
region      = "eu-west-1"
environment = "prod"
partition   = "aws"

# KMS Configuration
kms_deletion_window_in_days = 30

# Lifecycle Management
noncurrent_version_expiration_days = 90

# S3 Access Logging
enable_logging = true
logging_bucket = "123456789012-central-logs"

# IAM Access Control
create_iam_policies = true

terraform_admin_role_arns = [
  "arn:aws:iam::123456789012:role/GitHubActions-Terraform",
  "arn:aws:iam::123456789012:role/InfraAdmin"
]

terraform_read_only_role_arns = [
  "arn:aws:iam::123456789012:role/Developers",
  "arn:aws:iam::123456789012:role/SecurityTeam",
  "arn:aws:iam::123456789012:role/Auditors"
]

# CloudTrail Audit Logging
enable_cloudtrail = true

# Cross-Region Replication
enable_replication = true
replication_region = "us-west-2"

# Tags
tags = {
  Project     = "cloud-foundations"
  Environment = "prod"
  ManagedBy   = "Terraform"
  CostCenter  = "infrastructure"
  Compliance  = "soc2,iso27001"
  DataClass   = "confidential"
  Backup      = "enabled"
}
```

### Development Environment (Minimal)

```hcl
# terraform.tfvars

# Basic Configuration
account_id  = "123456789012"
region      = "eu-west-1"
environment = "dev"

# Reduced retention for dev
noncurrent_version_expiration_days = 30

# IAM policies but no replication
create_iam_policies = true
enable_cloudtrail   = false
enable_replication  = false

terraform_admin_role_arns = [
  "arn:aws:iam::123456789012:role/DevTeam"
]

tags = {
  Project     = "cloud-foundations"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
```

---

## Compliance Mapping

### SOC 2 Requirements

| Control | Implementation |
|---------|----------------|
| Access Control | IAM policies with role-based access |
| Encryption | KMS encryption at rest, TLS in transit |
| Audit Logging | CloudTrail logs all access |
| Versioning | S3 versioning with lifecycle |
| Backup | Cross-region replication |
| Monitoring | CloudWatch metrics and alarms |

### ISO 27001 Requirements

| Control | Implementation |
|---------|----------------|
| A.9.4.1 (Access restriction) | IAM policies with least privilege |
| A.10.1.1 (Cryptographic controls) | KMS with key rotation |
| A.12.4.1 (Event logging) | CloudTrail audit logs |
| A.12.3.1 (Backup) | S3 versioning + replication |
| A.18.1.3 (Records protection) | Encryption + access control |

### HIPAA Requirements

| Requirement | Implementation |
|-------------|----------------|
| §164.312(a)(1) Access Control | IAM policies |
| §164.312(a)(2)(iv) Encryption | KMS encryption |
| §164.308(a)(1)(ii)(D) Information System Activity Review | CloudTrail logs |
| §164.310(d)(2)(iv) Data Backup | Replication + versioning |

### PCI DSS Requirements

| Requirement | Implementation |
|-------------|----------------|
| 3.4 (Encryption at rest) | KMS encryption |
| 3.5.3 (Key management) | KMS with rotation |
| 10.2 (Audit logs) | CloudTrail |
| 10.7 (Log retention) | CloudTrail + S3 lifecycle |
| 7.1 (Access control) | IAM policies |

---

## Best Practices Summary

### Security
✅ Enable all security features in production
✅ Use separate IAM roles for different access levels
✅ Regularly review CloudTrail logs
✅ Enable MFA for admin roles
✅ Rotate KMS keys annually (automatic with key rotation)

### Compliance
✅ Enable CloudTrail for audit requirements
✅ Retain logs for required period (7 years for some regulations)
✅ Document access control procedures
✅ Regular access reviews

### Disaster Recovery
✅ Enable replication in production
✅ Test failover procedures quarterly
✅ Document recovery procedures
✅ Monitor replication lag

### Cost Optimization
✅ Adjust lifecycle policies based on needs
✅ Use replication only in production
✅ Monitor storage costs
✅ Clean up old state files when projects are retired

---

## Troubleshooting

### IAM Policy Issues

**Problem:** Role can't access state

**Solution:**
1. Verify policy is attached:
```bash
aws iam list-attached-role-policies --role-name ROLE-NAME
```

2. Check trust relationship:
```bash
aws iam get-role --role-name ROLE-NAME
```

3. Test with CloudTrail - look for AccessDenied events

### CloudTrail Not Logging

**Problem:** No logs appearing

**Solution:**
1. Verify trail is enabled:
```bash
aws cloudtrail get-trail-status --name terraform-state-prod
```

2. Check S3 bucket policy allows CloudTrail writes

3. Wait 15 minutes for logs to appear

### Replication Failures

**Problem:** Objects not replicating

**Solution:**
1. Check replication status:
```bash
aws s3api head-object \
  --bucket PRIMARY-BUCKET \
  --key path/to/terraform.tfstate
```

2. Verify IAM replication role permissions

3. Check KMS key policies allow cross-region access

4. Review CloudWatch metrics for replication lag

---

## Additional Resources

- [AWS CloudTrail Documentation](https://docs.aws.amazon.com/cloudtrail/)
- [S3 Replication Documentation](https://docs.aws.amazon.com/s3/replication/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/s3.html)
