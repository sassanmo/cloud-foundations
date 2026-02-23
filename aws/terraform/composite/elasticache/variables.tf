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

variable "cluster_id" {
  description = "Group identifier for the cache cluster"
  type        = string
}

variable "engine" {
  description = "Name of the cache engine to be used"
  type        = string
  default     = "redis"
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The initial number of cache nodes"
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "Name of the parameter group to associate"
  type        = string
  default     = null
}

variable "port" {
  description = "The port number on which the cache accepts connections"
  type        = number
  default     = null
}

variable "subnet_group_name" {
  description = "Name of the subnet group to be used for the cache cluster"
  type        = string
}

variable "security_group_ids" {
  description = "One or more VPC security groups associated with the cache cluster"
  type        = list(string)
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit"
  type        = bool
  default     = true
}

variable "snapshot_retention_limit" {
  description = "Number of days for which ElastiCache retains automatic cache cluster snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily time range during which ElastiCache takes daily snapshots"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range during which maintenance on the cache cluster is performed"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "apply_immediately" {
  description = "Whether any database modifications are applied immediately"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Whether minor version engine upgrades will be applied automatically"
  type        = bool
  default     = true
}

variable "notification_topic_arn" {
  description = "ARN of an Amazon SNS topic to send ElastiCache notifications to"
  type        = string
  default     = null
}

variable "kms_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "KMS key for ElastiCache cluster encryption"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
