output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_id" {
  description = "ID of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.id
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.name
}

output "state_machine_creation_date" {
  description = "Creation date of the state machine"
  value       = aws_sfn_state_machine.this.creation_date
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_role ? aws_iam_role.step_functions[0].arn : var.existing_role_arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = var.create_role ? aws_iam_role.step_functions[0].name : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.step_functions[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.step_functions[0].arn : null
}

