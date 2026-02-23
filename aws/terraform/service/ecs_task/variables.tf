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

variable "app_suffix" {
  description = "Suffix for the app name (used for task definition and service)"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "network_mode" {
  description = "Network mode for the task definition"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Launch types required by the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "Number of CPU units for the task"
  type        = string
}

variable "memory" {
  description = "Amount of memory (in MiB) for the task"
  type        = string
}

variable "container_definitions" {
  description = "Container definitions for the task"
  type        = list(any)
}

variable "volumes" {
  description = "List of volumes to attach to the task"
  type = list(object({
    name      = string
    host_path = optional(string)
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string, "/")
      transit_encryption      = optional(string, "ENABLED")
      transit_encryption_port = optional(number)
    }))
  }))
  default = []
}

variable "create_execution_role" {
  description = "Whether to create an ECS task execution role"
  type        = bool
  default     = true
}

variable "execution_role_arn" {
  description = "ARN of existing execution role (when create_execution_role is false)"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of IAM role for the task itself"
  type        = string
  default     = null
}

variable "execution_role_custom_policy_json" {
  description = "Custom IAM policy JSON for the execution role"
  type        = string
  default     = ""
}

variable "create_service" {
  description = "Whether to create an ECS service"
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type for the service"
  type        = string
  default     = "FARGATE"
}

variable "network_configuration" {
  description = "Network configuration for the service"
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = optional(bool, false)
  })
  default = null
}

variable "load_balancers" {
  description = "Load balancer configurations"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "service_registry_arn" {
  description = "ARN of service discovery registry"
  type        = string
  default     = null
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds"
  type        = number
  default     = null
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "log_kms_key_id" {
  description = "KMS key ID for log encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

