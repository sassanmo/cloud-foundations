variable "name" {
  description = "Name of the API Gateway REST API."
  type        = string
}

variable "description" {
  description = "Description of the REST API."
  type        = string
  default     = ""
}

variable "endpoint_type" {
  description = "Endpoint type for the REST API (REGIONAL, EDGE, or PRIVATE)."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "endpoint_type must be REGIONAL, EDGE, or PRIVATE."
  }
}

variable "stage_name" {
  description = "Name of the deployment stage."
  type        = string
  default     = "v1"
}

variable "logging_level" {
  description = "Logging level for the stage (OFF, ERROR, INFO)."
  type        = string
  default     = "ERROR"
}

variable "metrics_enabled" {
  description = "Enable CloudWatch metrics."
  type        = bool
  default     = true
}

variable "xray_tracing_enabled" {
  description = "Enable X-Ray tracing."
  type        = bool
  default     = true
}

variable "throttling_burst_limit" {
  description = "Throttling burst limit (-1 to disable)."
  type        = number
  default     = 500
}

variable "throttling_rate_limit" {
  description = "Throttling rate limit (-1 to disable)."
  type        = number
  default     = 1000
}

variable "minimum_compression_size" {
  description = "Minimum response size to compress (-1 to disable compression)."
  type        = number
  default     = 1024
}

variable "api_key_selection_expression" {
  description = "API key source (HEADER or AUTHORIZER)."
  type        = string
  default     = "HEADER"
}

variable "cloudwatch_role_arn" {
  description = "ARN of IAM role to allow API Gateway to write logs to CloudWatch."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
