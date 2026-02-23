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

variable "event_bus_suffix" {
  description = "Suffix for the event bus name"
  type        = string
  default     = "bus"
}

variable "create_event_bus" {
  description = "Whether to create a new event bus"
  type        = bool
  default     = true
}

variable "event_bus_name" {
  description = "Name of existing event bus to use (when create_event_bus is false)"
  type        = string
  default     = "default"
}

variable "rules" {
  description = "Map of EventBridge rules to create"
  type = map(object({
    description         = string
    event_pattern       = optional(string)
    schedule_expression = optional(string)
    is_enabled          = optional(bool, true)
  }))
  default = {}
}

variable "targets" {
  description = "Map of EventBridge targets"
  type = map(object({
    rule_key    = string
    arn         = string
    role_arn    = optional(string)
    input       = optional(string)
    input_transformer = optional(object({
      input_paths    = map(string)
      input_template = string
    }))
    retry_policy = optional(object({
      maximum_event_age      = optional(number, 86400)
      maximum_retry_attempts = optional(number, 185)
    }))
    dead_letter_arn = optional(string)
    ecs_target = optional(object({
      task_definition_arn = string
      task_count          = optional(number, 1)
      launch_type         = optional(string, "FARGATE")
      platform_version    = optional(string, "LATEST")
      network_configuration = optional(object({
        subnets          = list(string)
        security_groups  = optional(list(string), [])
        assign_public_ip = optional(bool, false)
      }))
    }))
  }))
  default = {}
}

variable "archives" {
  description = "Map of EventBridge archives to create"
  type = map(object({
    description    = string
    retention_days = optional(number, 0)
    event_pattern  = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

