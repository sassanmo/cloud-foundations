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

variable "efs_suffix" {
  description = "Suffix for the EFS file system name"
  type        = string
  default     = "efs"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "Performance mode (generalPurpose or maxIO)"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be generalPurpose or maxIO."
  }
}

variable "throughput_mode" {
  description = "Throughput mode (bursting, provisioned, or elastic)"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "Throughput mode must be bursting, provisioned, or elastic."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput in MiB/s (required if throughput_mode is provisioned)"
  type        = number
  default     = null
}

variable "lifecycle_policy_transition_to_ia" {
  description = "Transition to Infrequent Access after days (AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS)"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "lifecycle_policy_transition_to_primary_storage_class" {
  description = "Transition back to primary storage class (AFTER_1_ACCESS)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for mount targets"
  type        = list(string)
}

variable "enable_backup_policy" {
  description = "Enable automatic backups with AWS Backup"
  type        = bool
  default     = true
}

variable "file_system_policy" {
  description = "EFS file system policy JSON"
  type        = string
  default     = null
}

variable "access_points" {
  description = "Map of EFS access points"
  type = map(object({
    posix_user = object({
      gid            = number
      uid            = number
      secondary_gids = optional(list(number), [])
    })
    root_directory = object({
      path = string
      creation_info = object({
        owner_gid   = number
        owner_uid   = number
        permissions = string
      })
    })
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

