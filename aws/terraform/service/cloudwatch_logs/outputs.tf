output "log_group_name" {
  description = "The name of the log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "The ARN of the log group"
  value       = aws_cloudwatch_log_group.this.arn
}

output "log_stream_names" {
  description = "Map of log stream names"
  value       = { for k, v in aws_cloudwatch_log_stream.this : k => v.name }
}

output "metric_filter_names" {
  description = "Map of metric filter names"
  value       = { for k, v in aws_cloudwatch_log_metric_filter.this : k => v.name }
}
