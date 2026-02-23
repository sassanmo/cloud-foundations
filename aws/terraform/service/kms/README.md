# KMS Module

This module creates an AWS KMS Customer Managed Key (CMK) following AWS best practices.

## Features

- Automatic key rotation enabled by default
- Configurable deletion window (7-30 days)
- Custom key policy support
- Key alias creation

## Usage

```hcl
module "kms_key" {
  source = "../../service/kms"

  alias_name  = "alias/my-app-key"
  description = "KMS key for my application"

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
| alias_name | The display name of the key (alias). Must start with alias/. | `string` | n/a | yes |
| description | Description of the KMS key. | `string` | `"Managed by Terraform"` | no |
| deletion_window_in_days | Duration in days after which the key is deleted (7-30). | `number` | `30` | no |
| enable_key_rotation | Enable automatic key rotation. | `bool` | `true` | no |
| policy | A valid policy JSON document. | `string` | `""` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key_id | The globally unique identifier for the key. |
| key_arn | The Amazon Resource Name (ARN) of the key. |
| alias_arn | The ARN of the key alias. |
| alias_name | The display name of the alias. |
