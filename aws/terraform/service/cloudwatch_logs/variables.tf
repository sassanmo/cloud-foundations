variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group (will be prefixed with /{project}/{environment}/)"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 14
}

variable "kms_key_id" {
  description = "KMS key ID for log group encryption"
  type        = string
  default     = null
}

variable "log_group_tags" {
  description = "Additional tags for the log group"
  type        = map(string)
  default     = {}
}

variable "log_streams" {
  description = "Map of CloudWatch log streams to create"
  type = map(object({
    stream_name = string
  }))
  default = {}
}

variable "metric_filters" {
  description = "Map of CloudWatch log metric filters"
  type = map(object({
    pattern              = string
    metric_name          = string
    metric_namespace     = string
    metric_value         = string
    metric_default_value = optional(number)
    metric_unit          = optional(string, "None")
  }))
  default = {}
}

variable "subscription_filters" {
  description = "Map of CloudWatch log subscription filters"
  type = map(object({
    filter_pattern  = string
    destination_arn = string
    role_arn        = optional(string)
  }))
  default = {}
}

variable "query_definitions" {
  description = "Map of CloudWatch Insights query definitions"
  type = map(object({
    query_string = string
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
