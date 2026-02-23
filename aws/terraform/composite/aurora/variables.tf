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

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "The engine version"
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The database engine mode"
  type        = string
  default     = "provisioned"
}

variable "database_name" {
  description = "The name of the database"
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

variable "instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 1
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The backup retention period"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which maintenance can occur"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any modifications are applied immediately"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "serverlessv2_scaling_configuration" {
  description = "Nested attribute with scaling properties for ServerlessV2"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "kms_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "KMS key for Aurora cluster encryption"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
