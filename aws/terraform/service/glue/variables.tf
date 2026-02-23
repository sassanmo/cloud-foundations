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

variable "database_suffix" {
  description = "Suffix for the Glue database name"
  type        = string
  default     = "glue"
}

variable "description" {
  description = "Description of the Glue database"
  type        = string
  default     = ""
}

variable "target_database" {
  description = "Target database configuration for federated database"
  type = object({
    catalog_id    = string
    database_name = string
  })
  default = null
}

variable "crawlers" {
  description = "Map of Glue crawlers"
  type = map(object({
    role_arn    = string
    description = optional(string)
    s3_targets = list(object({
      path                = string
      connection_name     = optional(string)
      exclusions          = optional(list(string), [])
      sample_size         = optional(number)
      event_queue_arn     = optional(string)
      dlq_event_queue_arn = optional(string)
    }))
    jdbc_targets = optional(list(object({
      connection_name = string
      path            = string
      exclusions      = optional(list(string))
    })))
    schema_change_policy = optional(object({
      delete_behavior = optional(string, "LOG")
      update_behavior = optional(string, "UPDATE_IN_DATABASE")
    }))
    schedule = optional(string)
  }))
  default = {}
}

variable "jobs" {
  description = "Map of Glue jobs"
  type = map(object({
    role_arn          = string
    description       = optional(string)
    glue_version      = optional(string, "4.0")
    command_name      = optional(string, "glueetl")
    script_location   = string
    python_version    = optional(string, "3")
    default_arguments = optional(map(string), {})
    max_retries       = optional(number, 0)
    timeout           = optional(number, 2880)
    max_capacity      = optional(number)
    number_of_workers = optional(number)
    worker_type       = optional(string)
    max_concurrent_runs = optional(number)
  }))
  default = {}
}

variable "triggers" {
  description = "Map of Glue triggers"
  type = map(object({
    description = optional(string)
    type        = string
    enabled     = optional(bool, true)
    schedule    = optional(string)
    job_key     = string
    arguments   = optional(map(string))
    timeout     = optional(number)
    predicate = optional(object({
      logical = string
      conditions = list(object({
        job_name         = optional(string)
        state            = optional(string)
        logical_operator = optional(string)
        crawl_state      = optional(string)
        crawler_name     = optional(string)
      }))
    }))
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

