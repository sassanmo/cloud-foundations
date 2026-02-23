output "order_events_topic_arn" {
  description = "ARN of the order events SNS topic."
  value       = module.order_events.sns_topic_arn
}

output "order_events_queue_arn" {
  description = "ARN of the order events SQS queue."
  value       = module.order_events.sqs_queue_arn
}

output "processing_queue_arn" {
  description = "ARN of the processing SQS queue."
  value       = module.processing_queue.queue_arn
}
