variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "definition" {
  description = "Amazon States Language definition of the state machine"
  type        = string
}

variable "type" {
  description = "Determines whether a Standard or Express state machine is created"
  type        = string
  default     = "STANDARD"
}

variable "include_execution_data" {
  description = "Determines whether execution data is included in your log"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Defines which category of execution history events are logged"
  type        = string
  default     = "ERROR"
}

variable "tracing_enabled" {
  description = "Whether to enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the Step Functions role"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log group retention period in days"
  type        = number
  default     = 14
}

variable "log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
