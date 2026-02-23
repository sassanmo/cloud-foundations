variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string
}

variable "kms_alias_name" {
  description = "KMS key alias name (must start with alias/)."
  type        = string
  default     = ""
}

variable "kms_description" {
  description = "Description for the KMS key."
  type        = string
  default     = "KMS key for S3 bucket encryption"
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days (7-30)."
  type        = number
  default     = 30
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket."
  type = list(object({
    id      = string
    enabled = bool
    expiration_days = optional(number)
    noncurrent_version_expiration_days = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
