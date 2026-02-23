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

variable "kms_key_suffix" {
  description = "Suffix for the KMS key alias"
  type        = string
  default     = "secrets"
}

variable "kms_key_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for Secrets Manager encryption"
}

variable "kms_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 30
}

variable "kms_enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "kms_key_administrators" {
  description = "List of IAM ARNs that can administer the KMS key"
  type        = list(string)
  default     = []
}

variable "kms_key_users" {
  description = "List of IAM ARNs that can use the KMS key"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    description             = optional(string, "")
    secret_string           = optional(string)
    secret_key_value        = optional(map(string))
    recovery_window_in_days = optional(number, 30)
    rotation = optional(object({
      enabled       = bool
      lambda_arn    = string
      rotation_days = optional(number, 30)
    }))
    policy = optional(string)
    tags   = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

