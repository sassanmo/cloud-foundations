# SNS Module

This module creates a secure AWS SNS topic following AWS best practices.

## Features

- Server-side encryption with KMS
- FIFO topic support
- Topic policy with least-privilege default
- Subscriptions management

## Usage

```hcl
module "sns_topic" {
  source = "../../service/sns"

  name              = "my-notifications"
  kms_master_key_id = "alias/aws/sns"

  subscriptions = [
    {
      protocol = "email"
      endpoint = "alerts@example.com"
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
| name | The name of the SNS topic. | `string` | n/a | yes |
| fifo_topic | Whether the topic is a FIFO topic. | `bool` | `false` | no |
| kms_master_key_id | KMS key ID or alias for encryption. | `string` | `""` | no |
| topic_policy | JSON formatted policy for the topic. | `string` | `""` | no |
| subscriptions | List of subscriptions to create. | `list(object)` | `[]` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| topic_arn | The ARN of the SNS topic. |
| topic_id | The ID of the SNS topic. |
| topic_name | The name of the SNS topic. |
