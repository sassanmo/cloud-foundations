output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = module.sns.topic_arn
}

output "sns_topic_name" {
  description = "The name of the SNS topic."
  value       = module.sns.topic_name
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue."
  value       = module.sqs.queue_arn
}

output "sqs_queue_id" {
  description = "The URL of the SQS queue."
  value       = module.sqs.queue_id
}

output "sqs_queue_name" {
  description = "The name of the SQS queue."
  value       = module.sqs.queue_name
}

output "sqs_dlq_arn" {
  description = "The ARN of the dead letter queue."
  value       = module.sqs.dlq_arn
}
