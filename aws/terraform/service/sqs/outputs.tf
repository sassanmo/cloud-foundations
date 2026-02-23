output "queue_id" {
  description = "The URL of the SQS queue."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue."
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "The name of the SQS queue."
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "The ARN of the dead letter queue (if created)."
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_id" {
  description = "The URL of the dead letter queue (if created)."
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}
