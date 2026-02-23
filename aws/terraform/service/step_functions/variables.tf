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

variable "state_machine_suffix" {
  description = "Suffix for the state machine name"
  type        = string
}

variable "definition" {
  description = "Amazon States Language definition of the state machine"
  type        = string
}

variable "state_machine_type" {
  description = "Type of state machine (STANDARD or EXPRESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.state_machine_type)
    error_message = "State machine type must be STANDARD or EXPRESS."
  }
}

variable "create_role" {
  description = "Whether to create an IAM role for the state machine"
  type        = bool
  default     = true
}

variable "existing_role_arn" {
  description = "ARN of existing IAM role to use (when create_role is false)"
  type        = string
  default     = null
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON to attach to the state machine role"
  type        = string
  default     = ""
}

variable "logging_configuration" {
  description = "Logging configuration for the state machine"
  type = object({
    log_group_arn          = string
    include_execution_data = optional(bool, false)
    level                  = optional(string, "ERROR")
  })
  default = null
}

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 14
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log group encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

