output "api_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = module.api_gateway.api_arn
}

output "api_endpoint" {
  description = "URI of the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "stage_arn" {
  description = "ARN of the stage"
  value       = module.api_gateway.stage_arn
}

output "stage_invoke_url" {
  description = "URL to invoke the API pointing to the stage"
  value       = module.api_gateway.stage_invoke_url
}

output "lambda_function_arn" {
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
  value       = module.lambda.function_arn
}

output "lambda_function_name" {
  description = "Unique name of your Lambda Function"
  value       = module.lambda.function_name
}

output "lambda_invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway"
  value       = module.lambda.invoke_arn
}

output "lambda_role_arn" {
  description = "Amazon Resource Name (ARN) of the Lambda IAM role"
  value       = module.lambda.role_arn
}

output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = module.lambda.log_group_name
}

# Lambda Secrets Manager Outputs (only available when secrets are provided)
output "lambda_secret_arn" {
  description = "ARN of the Lambda Secrets Manager secret"
  value       = module.lambda.secret_arn
}

output "lambda_secret_name" {
  description = "Name of the Lambda Secrets Manager secret"
  value       = module.lambda.secret_name
}

output "lambda_secret_kms_key_arn" {
  description = "ARN of the KMS key used for Lambda secrets encryption"
  value       = module.lambda.secret_kms_key_arn
}

output "lambda_secret_kms_key_id" {
  description = "ID of the KMS key used for Lambda secrets encryption"
  value       = module.lambda.secret_kms_key_id
}
