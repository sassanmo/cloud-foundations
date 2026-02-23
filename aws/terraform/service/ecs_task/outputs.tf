output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.this.revision
}

output "service_id" {
  description = "ID of the ECS service"
  value       = var.create_service ? aws_ecs_service.this[0].id : null
}

output "service_name" {
  description = "Name of the ECS service"
  value       = var.create_service ? aws_ecs_service.this[0].name : null
}

output "execution_role_arn" {
  description = "ARN of the execution role"
  value       = var.create_execution_role ? aws_iam_role.execution[0].arn : var.execution_role_arn
}

output "execution_role_name" {
  description = "Name of the execution role"
  value       = var.create_execution_role ? aws_iam_role.execution[0].name : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}

