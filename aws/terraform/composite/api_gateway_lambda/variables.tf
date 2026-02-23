variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = null
}

variable "protocol_type" {
  description = "API protocol type"
  type        = string
  default     = "HTTP"
}

variable "route_key" {
  description = "Route key for the API Gateway"
  type        = string
  default     = "ANY /{proxy+}"
}

variable "cors_configuration" {
  description = "CORS configuration for the API Gateway"
  type = object({
    allow_credentials = bool
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age          = number
  })
  default = null
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Whether deployments are automatically triggered"
  type        = bool
  default     = true
}

variable "throttle_settings" {
  description = "Throttle settings for the API Gateway"
  type = object({
    burst_limit = number
    rate_limit  = number
  })
  default = null
}

variable "access_log_destination_arn" {
  description = "ARN of the CloudWatch Logs log group for access logs"
  type        = string
  default     = null
}

variable "access_log_format" {
  description = "Format of the access logs"
  type        = string
  default     = null
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_filename" {
  description = "Path to the Lambda function's deployment package"
  type        = string
  default     = null
}

variable "lambda_source_code_hash" {
  description = "Used to trigger updates to the Lambda function"
  type        = string
  default     = null
}

variable "lambda_s3_bucket" {
  description = "S3 bucket location containing the Lambda function's deployment package"
  type        = string
  default     = null
}

variable "lambda_s3_key" {
  description = "S3 key of an object containing the Lambda function's deployment package"
  type        = string
  default     = null
}

variable "lambda_s3_object_version" {
  description = "Object version containing the Lambda function's deployment package"
  type        = string
  default     = null
}

variable "lambda_handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "lambda_runtime" {
  description = "Identifier of the function's runtime"
  type        = string
}

variable "lambda_timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "lambda_architectures" {
  description = "Instruction set architecture for your Lambda function"
  type        = list(string)
  default     = ["x86_64"]
}

variable "lambda_publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = false
}

variable "lambda_layers" {
  description = "List of Lambda Layer Version ARNs"
  type        = list(string)
  default     = []
}

variable "lambda_environment_variables" {
  description = "Map of environment variables that are accessible from the function code"
  type        = map(string)
  default     = {}
}

variable "lambda_additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log group retention period in days for Lambda"
  type        = number
  default     = 14
}

variable "lambda_secrets" {
  description = "Map of secrets to store in AWS Secrets Manager for the Lambda function"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
