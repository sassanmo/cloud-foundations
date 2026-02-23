variable "region" {
  description = "AWS region where the state backend resources will be created"
  type        = string
  default     = "eu-west-1"
}

variable "account_id" {
  description = "AWS account ID (used for bucket naming)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "kms_deletion_window_in_days" {
  description = "Duration in days after which the KMS key is deleted after destruction (7-30)"
  type        = number
  default     = 30
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days to keep noncurrent versions of state files"
  type        = number
  default     = 90
}

variable "enable_logging" {
  description = "Enable S3 bucket access logging"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "S3 bucket for storing access logs (if different from state bucket)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# IAM Access Control
variable "terraform_admin_role_arns" {
  description = "List of IAM role ARNs that have full access to state (e.g., CI/CD roles)"
  type        = list(string)
  default     = []
}

variable "terraform_read_only_role_arns" {
  description = "List of IAM role ARNs that have read-only access to state (e.g., developer roles)"
  type        = list(string)
  default     = []
}

variable "create_iam_policies" {
  description = "Create IAM policies for Terraform state access"
  type        = bool
  default     = true
}

# CloudTrail Configuration
variable "enable_cloudtrail" {
  description = "Enable CloudTrail logging for state bucket access"
  type        = bool
  default     = true
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs (will be created if enable_cloudtrail is true)"
  type        = string
  default     = ""
}

# Replication Configuration
variable "enable_replication" {
  description = "Enable S3 replication to a backup region"
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "AWS region for replication backup (must be different from primary region)"
  type        = string
  default     = ""
}

variable "partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

