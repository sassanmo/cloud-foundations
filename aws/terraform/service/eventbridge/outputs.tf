output "event_bus_name" {
  description = "Name of the EventBridge event bus"
  value       = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].name : var.event_bus_name
}

output "event_bus_arn" {
  description = "ARN of the EventBridge event bus"
  value       = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].arn : data.aws_cloudwatch_event_bus.existing[0].arn
}

output "rule_arns" {
  description = "Map of EventBridge rule ARNs"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}

output "rule_names" {
  description = "Map of EventBridge rule names"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.name }
}

output "archive_arns" {
  description = "Map of EventBridge archive ARNs"
  value       = { for k, v in aws_cloudwatch_event_archive.this : k => v.arn }
}

