output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.step_functions.state_machine_arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = module.step_functions.state_machine_name
}

output "state_machine_creation_date" {
  description = "Date the state machine was created"
  value       = module.step_functions.state_machine_creation_date
}

output "state_machine_status" {
  description = "Current status of the state machine"
  value       = module.step_functions.state_machine_status
}

output "role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = module.iam_role.arn
}

output "role_name" {
  description = "Name of the Step Functions IAM role"
  value       = module.iam_role.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.cloudwatch_logs.log_group_arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch_logs.log_group_name
}
