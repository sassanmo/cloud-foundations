output "api_id" {
  description = "The ID of the REST API."
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "The ARN of the REST API."
  value       = aws_api_gateway_rest_api.this.arn
}

output "root_resource_id" {
  description = "The resource ID of the REST API root."
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "stage_invoke_url" {
  description = "The URL to invoke the API pointing to the stage."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "stage_arn" {
  description = "The ARN of the API Gateway stage."
  value       = aws_api_gateway_stage.this.arn
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for API Gateway logs."
  value       = aws_cloudwatch_log_group.this.arn
}
