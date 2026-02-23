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

variable "cluster_identifier" {
  description = "The cluster identifier"
  type        = string
}

variable "engine_version" {
  description = "The engine version"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "A DB subnet group to associate with this DB instance"
  type        = string
}

variable "backup_retention_period" {
  description = "The backup retention period"
  type        = number
  default     = 5
}

variable "preferred_backup_window" {
  description = "The daily time range during which backups are created"
  type        = string
  default     = "07:00-09:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "A value that indicates whether the DB cluster has deletion protection enabled"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any modifications are applied immediately"
  type        = bool
  default     = false
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.t3.medium"
}

variable "kms_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "KMS key for DocumentDB cluster encryption"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
