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

variable "creation_token" {
  description = "A unique name used as reference when creating the EFS file system"
  type        = string
}

variable "performance_mode" {
  description = "The file system performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system"
  type        = number
  default     = null
}

variable "mount_targets" {
  description = "Mount targets for the EFS file system"
  type = list(object({
    subnet_id       = string
    security_groups = list(string)
  }))
  default = []
}

variable "access_points" {
  description = "Access points for the EFS file system"
  type = list(object({
    name = string
    path = string
    posix_user = object({
      gid = number
      uid = number
    })
    creation_info = object({
      owner_gid   = number
      owner_uid   = number
      permissions = string
    })
  }))
  default = []
}

variable "backup_policy_status" {
  description = "A boolean that indicates whether automatic backups are enabled"
  type        = string
  default     = "ENABLED"
}

variable "kms_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "KMS key for EFS file system encryption"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
