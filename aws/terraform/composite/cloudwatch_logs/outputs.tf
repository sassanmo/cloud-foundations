output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.cloudwatch_logs.log_group_arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch_logs.log_group_name
}

output "log_group_retention_in_days" {
  description = "Number of days log events are retained"
  value       = module.cloudwatch_logs.log_group_retention_in_days
}

output "log_stream_arns" {
  description = "ARNs of the CloudWatch log streams"
  value       = module.cloudwatch_logs.log_stream_arns
}

output "log_stream_names" {
  description = "Names of the CloudWatch log streams"
  value       = module.cloudwatch_logs.log_stream_names
}

output "metric_filter_names" {
  description = "Names of the CloudWatch log metric filters"
  value       = module.cloudwatch_logs.metric_filter_names
}

output "subscription_filter_names" {
  description = "Names of the CloudWatch log subscription filters"
  value       = module.cloudwatch_logs.subscription_filter_names
}

output "query_definition_ids" {
  description = "IDs of the CloudWatch Insights query definitions"
  value       = module.cloudwatch_logs.query_definition_ids
}

output "query_definition_names" {
  description = "Names of the CloudWatch Insights query definitions"
  value       = module.cloudwatch_logs.query_definition_names
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = module.kms.key_id
}
