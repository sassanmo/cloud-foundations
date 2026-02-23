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

variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string
}

variable "kms_alias_name" {
  description = "KMS key alias name (must start with alias/)."
  type        = string
  default     = ""
}

variable "kms_description" {
  description = "Description for the KMS key."
  type        = string
  default     = "KMS key for S3 bucket encryption"
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days (7-30)."
  type        = number
  default     = 30
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
}
