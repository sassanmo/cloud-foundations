variable "name" {
  description = "The name of the SQS queue."
  type        = string
}

variable "fifo_queue" {
  description = "Whether the queue is a FIFO queue."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (only for FIFO queues)."
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue (0-43200 seconds)."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message (60-1209600)."
  type        = number
  default     = 345600  # 4 days
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain (1024-262144)."
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "The time in seconds that delivery of all messages is delayed (0-900)."
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message (0-20 seconds)."
  type        = number
  default     = 20  # Long polling enabled by default
}

variable "kms_master_key_id" {
  description = "The ID of an AWS managed or customer managed key to encrypt messages."
  type        = string
  default     = ""
}

variable "create_dlq" {
  description = "Whether to create a dead letter queue."
  type        = bool
  default     = true
}

variable "dlq_max_receive_count" {
  description = "The number of times a message can be received before being sent to the DLQ."
  type        = number
  default     = 3
}

variable "queue_policy" {
  description = "JSON formatted policy for the queue."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
