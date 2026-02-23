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

variable "secret_suffix" {
  description = "Suffix for the secret name"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "secret_string" {
  description = "Secret value as a plain string"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_key_value" {
  description = "Secret value as a map (will be converted to JSON)"
  type        = map(string)
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Recovery window in days (7-30)"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30
    error_message = "Recovery window must be between 7 and 30 days."
  }
}

variable "rotation" {
  description = "Secret rotation configuration"
  type = object({
    enabled       = bool
    lambda_arn    = string
    rotation_days = optional(number, 30)
  })
  default = null
}

variable "policy" {
  description = "Resource policy for the secret"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
