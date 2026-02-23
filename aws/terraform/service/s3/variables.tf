variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for bucket encryption. If empty, uses AES256."
  type        = string
  default     = ""
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket."
  type = list(object({
    id      = string
    enabled = bool
    expiration_days = optional(number)
    noncurrent_version_expiration_days = optional(number)
  }))
  default = []
}

variable "enable_logging" {
  description = "Enable S3 bucket access logging."
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Target bucket for access logs. If empty, logs to itself."
  type        = string
  default     = ""
}

variable "logging_target_prefix" {
  description = "Prefix for access log objects."
  type        = string
  default     = "logs/"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
