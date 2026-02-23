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

variable "domain" {
  description = "Domain name for SES"
  type        = string
}

variable "mail_from_domain" {
  description = "Custom MAIL FROM domain"
  type        = string
  default     = null
}

variable "email_identities" {
  description = "List of email addresses to verify"
  type        = list(string)
  default     = []
}

variable "reputation_metrics_enabled" {
  description = "Enable reputation metrics"
  type        = bool
  default     = true
}

variable "event_destinations" {
  description = "Map of SES event destinations"
  type = map(object({
    enabled        = optional(bool, true)
    matching_types = list(string)
    cloudwatch_destination = optional(object({
      default_value  = string
      dimension_name = string
      value_source   = string
    }))
    sns_topic_arn = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

