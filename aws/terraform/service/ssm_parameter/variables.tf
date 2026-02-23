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

variable "parameter_name" {
  description = "Name of the SSM parameter (will be prefixed with /project/environment/)"
  type        = string
}

variable "description" {
  description = "Description of the parameter"
  type        = string
  default     = ""
}

variable "type" {
  description = "Type of the parameter (String, StringList, or SecureString)"
  type        = string
  default     = "SecureString"
  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.type)
    error_message = "Valid values are String, StringList, or SecureString"
  }
}

variable "value" {
  description = "Value of the parameter"
  type        = string
  sensitive   = true
}

variable "tier" {
  description = "Parameter tier (Standard, Advanced, or Intelligent-Tiering)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.tier)
    error_message = "Valid values are Standard, Advanced, or Intelligent-Tiering"
  }
}

variable "kms_key_id" {
  description = "KMS key ID for SecureString encryption"
  type        = string
  default     = null
}

variable "allowed_pattern" {
  description = "Regular expression to validate parameter value"
  type        = string
  default     = null
}

variable "data_type" {
  description = "Data type of the parameter (text, aws:ec2:image, aws:ssm:integration)"
  type        = string
  default     = "text"
}

variable "overwrite" {
  description = "Overwrite an existing parameter"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

