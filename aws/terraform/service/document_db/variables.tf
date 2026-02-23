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
  description = "Identifier for the DocumentDB cluster."
  type        = string
}

variable "engine_version" {
  description = "DocumentDB engine version."
  type        = string
  default     = "5.0.0"
}

variable "instance_count" {
  description = "Number of instances in the cluster."
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class for the DocumentDB instances."
  type        = string
  default     = "db.t3.medium"
}

variable "master_username" {
  description = "Master username for the DocumentDB cluster."
  type        = string
}

variable "master_password" {
  description = "Master password for the DocumentDB cluster."
  type        = string
  sensitive   = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs."
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group."
  type        = string
}

variable "storage_encrypted" {
  description = "Enable storage encryption."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption."
  type        = string
  default     = ""
}

variable "backup_retention_period" {
  description = "Backup retention period in days (1-35)."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window (hh24:mi-hh24:mi UTC)."
  type        = string
  default     = "03:00-05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot."
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately or during the next maintenance window."
  type        = bool
  default     = false
}

variable "cluster_parameter_group_name" {
  description = "Name of the cluster parameter group."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
