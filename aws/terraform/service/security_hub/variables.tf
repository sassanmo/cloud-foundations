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

variable "enable_security_hub" {
  description = "Whether to enable Security Hub"
  type        = bool
  default     = true
}

variable "enable_default_standards" {
  description = "Whether to enable default security standards"
  type        = bool
  default     = true
}

variable "control_finding_generator" {
  description = "Updates whether the calling account has consolidated control findings turned on"
  type        = string
  default     = "SECURITY_CONTROL"
  validation {
    condition     = contains(["SECURITY_CONTROL", "STANDARD_CONTROL"], var.control_finding_generator)
    error_message = "Valid values are SECURITY_CONTROL or STANDARD_CONTROL"
  }
}

variable "auto_enable_controls" {
  description = "Whether to automatically enable new controls when they are added to standards"
  type        = bool
  default     = true
}

variable "enable_cis_standard" {
  description = "Whether to enable CIS AWS Foundations Benchmark"
  type        = bool
  default     = true
}

variable "enable_aws_foundational_standard" {
  description = "Whether to enable AWS Foundational Security Best Practices"
  type        = bool
  default     = true
}

variable "enable_pci_dss_standard" {
  description = "Whether to enable PCI DSS"
  type        = bool
  default     = false
}

variable "enable_nist_standard" {
  description = "Whether to enable NIST 800-53"
  type        = bool
  default     = false
}

variable "action_target_name" {
  description = "Name for the custom action target"
  type        = string
  default     = null
}

variable "action_target_description" {
  description = "Description for the custom action target"
  type        = string
  default     = ""
}

variable "action_target_identifier" {
  description = "Identifier for the custom action target"
  type        = string
  default     = null
}

variable "member_accounts" {
  description = "List of member account IDs to invite to Security Hub"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

