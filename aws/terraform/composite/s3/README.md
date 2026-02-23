# S3 with KMS Composite Module

This composite module creates an S3 bucket with a dedicated KMS Customer Managed Key (CMK) for server-side encryption.

## Features

- Dedicated KMS CMK with automatic key rotation
- S3 bucket with KMS encryption
- All S3 best practices (public access blocked, versioning)
- Lifecycle rules support

## Usage

```hcl
module "s3_with_kms" {
  source = "../../composite/s3_with_kms"

  bucket_name    = "my-encrypted-bucket"
  kms_alias_name = "alias/my-bucket-key"

  lifecycle_rules = [
    {
      id      = "expire-old-versions"
      enabled = true
      noncurrent_version_expiration_days = 90
    }
  ]

  tags = {
    Environment = "production"
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
| bucket_name | Name of the S3 bucket. | `string` | n/a | yes |
| kms_alias_name | KMS key alias (must start with alias/). | `string` | `""` | no |
| kms_description | Description for the KMS key. | `string` | `"KMS key for S3 bucket encryption"` | no |
| kms_deletion_window_in_days | KMS key deletion window (7-30 days). | `number` | `30` | no |
| versioning_enabled | Enable S3 versioning. | `bool` | `true` | no |
| force_destroy | Allow bucket deletion with objects. | `bool` | `false` | no |
| lifecycle_rules | List of lifecycle rules. | `list(object)` | `[]` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the S3 bucket. |
| bucket_arn | The ARN of the S3 bucket. |
| kms_key_id | The ID of the KMS key. |
| kms_key_arn | The ARN of the KMS key. |
| kms_alias_name | The alias name of the KMS key. |
