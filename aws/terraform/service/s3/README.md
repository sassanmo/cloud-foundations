# S3 Module

This module creates a secure AWS S3 bucket following AWS best practices.

## Features

- Server-side encryption (AES256 or KMS)
- Versioning support
- Public access block (all public access blocked by default)
- Lifecycle rules support
- Access logging (optional)

## Usage

### Basic Usage

```hcl
module "s3_bucket" {
  source = "../../service/s3"

  bucket_name        = "my-secure-bucket"
  versioning_enabled = true
  kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/..."

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### With Access Logging

```hcl
module "s3_bucket" {
  source = "../../service/s3"

  bucket_name        = "my-secure-bucket"
  versioning_enabled = true
  
  # Enable access logging
  enable_logging         = true
  logging_target_bucket  = "my-logging-bucket"  # Optional, defaults to self
  logging_target_prefix  = "access-logs/"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket. Must be globally unique. | `string` | n/a | yes |
| versioning_enabled | Enable versioning on the S3 bucket. | `bool` | `true` | no |
| force_destroy | Allow bucket to be destroyed even if it contains objects. | `bool` | `false` | no |
| kms_key_arn | ARN of the KMS key for encryption. If empty, uses AES256. | `string` | `""` | no |
| lifecycle_rules | List of lifecycle rules for the bucket. | `list(object)` | `[]` | no |
| enable_logging | Enable S3 bucket access logging. | `bool` | `false` | no |
| logging_target_bucket | Target bucket for access logs. If empty, logs to itself. | `string` | `""` | no |
| logging_target_prefix | Prefix for access log objects. | `string` | `"logs/"` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket. |
| bucket_arn | The ARN of the bucket. |
| bucket_regional_domain_name | The bucket region-specific domain name. |
