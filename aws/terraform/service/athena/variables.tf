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

variable "workgroup_suffix" {
  description = "Suffix for the Athena workgroup name"
  type        = string
  default     = "workgroup"
}

variable "description" {
  description = "Description of the workgroup"
  type        = string
  default     = ""
}

variable "state" {
  description = "State of the workgroup (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.state)
    error_message = "State must be ENABLED or DISABLED."
  }
}

variable "enforce_workgroup_configuration" {
  description = "Enforce workgroup configuration for queries"
  type        = bool
  default     = true
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Publish CloudWatch metrics"
  type        = bool
  default     = true
}

variable "bytes_scanned_cutoff_per_query" {
  description = "Bytes scanned cutoff per query (0 means unlimited)"
  type        = number
  default     = null
}

variable "output_location" {
  description = "S3 location for query results"
  type        = string
}

variable "encryption_configuration" {
  description = "Encryption configuration for query results"
  type = object({
    encryption_option = string
    kms_key_arn       = optional(string)
  })
  default = null
}

variable "engine_version" {
  description = "Engine version for Athena"
  type        = string
  default     = "AUTO"
}

variable "databases" {
  description = "Map of Athena databases to create"
  type = map(object({
    bucket        = string
    comment       = optional(string)
    force_destroy = optional(bool, false)
    encryption_configuration = optional(object({
      encryption_option = string
      kms_key           = optional(string)
    }))
  }))
  default = {}
}

variable "named_queries" {
  description = "Map of named queries"
  type = map(object({
    database    = string
    query       = string
    description = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

