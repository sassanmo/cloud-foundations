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

variable "username" {
  description = "Master username."
  type        = string
}

variable "password" {
  description = "Master password."
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs."
  type        = list(string)
  default     = []
}

variable "kms_alias_name" {
  description = "KMS key alias name (must start with alias/)."
  type        = string
  default     = ""
}

variable "kms_description" {
  description = "Description for the KMS key."
  type        = string
  default     = "KMS key for RDS encryption"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
