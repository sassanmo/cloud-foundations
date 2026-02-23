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

variable "cache_suffix" {
  description = "Suffix for the cache cluster name"
  type        = string
  default     = "valkey"
}

variable "description" {
  description = "Description of the replication group"
  type        = string
  default     = ""
}

variable "engine" {
  description = "Cache engine (valkey or memcached)"
  type        = string
  default     = "valkey"

  validation {
    condition     = contains(["valkey", "redis", "memcached"], var.engine)
    error_message = "Engine must be valkey, redis (deprecated), or memcached."
  }
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "7.2"
}

variable "node_type" {
  description = "Instance type for cache nodes"
  type        = string
  default     = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes)"
  type        = number
  default     = 2
}

variable "parameter_group_name" {
  description = "Name of parameter group"
  type        = string
  default     = null
}

variable "port" {
  description = "Port number"
  type        = number
  default     = 6379
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "auth_token_enabled" {
  description = "Enable Valkey/Redis AUTH"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Auth token (password) for Valkey/Redis"
  type        = string
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily snapshot window"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "slow_log_destination" {
  description = "CloudWatch log group for slow logs"
  type        = string
  default     = null
}

variable "engine_log_destination" {
  description = "CloudWatch log group for engine logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
