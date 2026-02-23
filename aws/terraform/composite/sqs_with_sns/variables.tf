variable "name" {
  description = "Base name for the SNS topic and SQS queue."
  type        = string
}

variable "kms_master_key_id" {
  description = "KMS key ID or alias for SNS and SQS encryption."
  type        = string
  default     = ""
}

variable "fifo" {
  description = "Whether to create FIFO topic and queue."
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "SQS queue visibility timeout seconds."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "SQS message retention period in seconds."
  type        = number
  default     = 345600
}

variable "dlq_max_receive_count" {
  description = "Max receive count before sending to DLQ."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
