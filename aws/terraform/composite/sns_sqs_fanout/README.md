# SQS with SNS Composite Module

This composite module creates an SNS topic with an SQS queue subscription, implementing the fan-out messaging pattern.

## Features

- SNS topic with SQS queue subscription
- Dead Letter Queue (DLQ) for the SQS queue
- KMS encryption for both SNS and SQS
- SQS queue policy allowing SNS to publish messages
- FIFO topic and queue support

## Usage

```hcl
module "notification_queue" {
  source = "../../composite/sqs_with_sns"

  name              = "order-events"
  kms_master_key_id = "alias/aws/sqs"

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
| name | Base name for the SNS topic and SQS queue. | `string` | n/a | yes |
| kms_master_key_id | KMS key ID or alias for encryption. | `string` | `""` | no |
| fifo | Whether to create FIFO topic and queue. | `bool` | `false` | no |
| visibility_timeout_seconds | SQS visibility timeout (seconds). | `number` | `30` | no |
| message_retention_seconds | SQS message retention (seconds). | `number` | `345600` | no |
| dlq_max_receive_count | Max receive count before DLQ. | `number` | `3` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | The ARN of the SNS topic. |
| sns_topic_name | The name of the SNS topic. |
| sqs_queue_arn | The ARN of the SQS queue. |
| sqs_queue_id | The URL of the SQS queue. |
| sqs_queue_name | The name of the SQS queue. |
| sqs_dlq_arn | The ARN of the dead letter queue. |
