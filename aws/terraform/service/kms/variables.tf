variable "description" {
  description = "Description of the KMS key."
  type        = string
  default     = "Managed by Terraform"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction (7-30)."
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation."
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "The display name of the key (alias). Must start with alias/."
  type        = string
}

variable "policy" {
  description = "A valid policy JSON document. If empty, the default key policy is used."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
