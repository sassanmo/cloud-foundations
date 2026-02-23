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

variable "identifier" {
  description = "Identifier for the RDS instance."
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., mysql, postgres)."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance class for the RDS instance."
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling (0 disables autoscaling)."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
  default     = ""
}

variable "username" {
  description = "Master username for the database."
  type        = string
}

variable "password" {
  description = "Master password for the database. Use secrets manager in production."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
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

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = true
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
  description = "Backup retention period in days (0-35)."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (hh24:mi-hh24:mi UTC)."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window."
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot."
  type        = string
  default     = ""
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group."
  type        = string
  default     = ""
}

variable "apply_immediately" {
  description = "Apply changes immediately or during the next maintenance window."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
