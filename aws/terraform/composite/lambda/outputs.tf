output "function_arn" {
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
  value       = module.lambda.function_arn
}

output "function_name" {
  description = "Unique name of your Lambda Function"
  value       = module.lambda.function_name
}

output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway"
  value       = module.lambda.invoke_arn
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version"
  value       = module.lambda.qualified_arn
}

output "version" {
  description = "Latest published version of your Lambda Function"
  value       = module.lambda.version
}

output "last_modified" {
  description = "Date this resource was last modified"
  value       = module.lambda.last_modified
}

output "source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = module.lambda.source_code_hash
}

output "source_code_size" {
  description = "Size in bytes of the function .zip file"
  value       = module.lambda.source_code_size
}

output "role_arn" {
  description = "Amazon Resource Name (ARN) of the IAM role"
  value       = module.iam_role.arn
}

output "role_name" {
  description = "Name of the IAM role"
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

# Secrets Manager Outputs (only available when secrets are provided)
output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = length(var.secrets) > 0 ? module.secrets_manager[0].secret_arn : null
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = length(var.secrets) > 0 ? module.secrets_manager[0].secret_name : null
}

output "secret_kms_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption"
  value       = length(var.secrets) > 0 ? module.secrets_manager[0].kms_key_arn : null
}

output "secret_kms_key_id" {
  description = "ID of the KMS key used for Secrets Manager encryption"
  value       = length(var.secrets) > 0 ? module.secrets_manager[0].kms_key_id : null
}
