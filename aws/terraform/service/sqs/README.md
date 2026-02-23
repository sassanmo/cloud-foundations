# SQS Module

This module creates a secure AWS SQS queue following AWS best practices.

## Features

- Server-side encryption with KMS
- Dead Letter Queue (DLQ) created by default
- Long polling enabled by default
- FIFO queue support

## Usage

```hcl
module "sqs_queue" {
  source = "../../service/sqs"

  name              = "my-queue"
  kms_master_key_id = "alias/aws/sqs"
  create_dlq        = true

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
| name | The name of the SQS queue. | `string` | n/a | yes |
| fifo_queue | Whether the queue is a FIFO queue. | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication (FIFO only). | `bool` | `false` | no |
| visibility_timeout_seconds | The visibility timeout (0-43200 seconds). | `number` | `30` | no |
| message_retention_seconds | Message retention period (60-1209600 seconds). | `number` | `345600` | no |
| max_message_size | Max message size in bytes. | `number` | `262144` | no |
| delay_seconds | Delivery delay (0-900 seconds). | `number` | `0` | no |
| receive_wait_time_seconds | Long polling wait time (0-20 seconds). | `number` | `20` | no |
| kms_master_key_id | KMS key ID or alias for encryption. | `string` | `""` | no |
| create_dlq | Whether to create a dead letter queue. | `bool` | `true` | no |
| dlq_max_receive_count | Max receive count before sending to DLQ. | `number` | `3` | no |
| queue_policy | JSON formatted policy for the queue. | `string` | `""` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| queue_id | The URL of the SQS queue. |
| queue_arn | The ARN of the SQS queue. |
| queue_name | The name of the SQS queue. |
| dlq_arn | The ARN of the dead letter queue. |
| dlq_id | The URL of the dead letter queue. |
