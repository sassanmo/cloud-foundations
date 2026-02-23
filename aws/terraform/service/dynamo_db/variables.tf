variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "billing_mode" {
  description = "Controls billing mode (PROVISIONED or PAY_PER_REQUEST)."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type        = string
}

variable "hash_key_type" {
  description = "Attribute type for the hash key (S, N, or B)."
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key."
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "Attribute type for the range key (S, N, or B)."
  type        = string
  default     = "S"
}

variable "read_capacity" {
  description = "Read capacity units (only for PROVISIONED billing mode)."
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only for PROVISIONED billing mode)."
  type        = number
  default     = 5
}

variable "enable_encryption" {
  description = "Enable server-side encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for server-side encryption. If empty, uses AWS managed key."
  type        = string
  default     = ""
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery."
  type        = bool
  default     = true
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute. Leave empty to disable TTL."
  type        = string
  default     = ""
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes."
  type = list(object({
    name               = string
    hash_key           = string
    hash_key_type      = string
    range_key          = optional(string)
    range_key_type     = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
