variable "name" {
  description = "The name of the SNS topic."
  type        = string
}

variable "fifo_topic" {
  description = "Whether the topic is a FIFO topic."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS managed or customer managed key to encrypt messages."
  type        = string
  default     = ""
}

variable "topic_policy" {
  description = "A JSON formatted policy for the topic. If empty, a default secure policy is created."
  type        = string
  default     = ""
}

variable "subscriptions" {
  description = "List of subscriptions to create for the topic."
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
