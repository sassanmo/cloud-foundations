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

variable "budget_name" {
  description = "Name suffix for the budget"
  type        = string
}

variable "budget_type" {
  description = "Type of budget (COST, USAGE, SAVINGS_PLANS_UTILIZATION, or RI_UTILIZATION)"
  type        = string
  default     = "COST"
  validation {
    condition     = contains(["COST", "USAGE", "SAVINGS_PLANS_UTILIZATION", "RI_UTILIZATION", "RI_COVERAGE"], var.budget_type)
    error_message = "Valid values are COST, USAGE, SAVINGS_PLANS_UTILIZATION, RI_UTILIZATION, or RI_COVERAGE"
  }
}

variable "limit_amount" {
  description = "The amount of cost or usage being measured for a budget"
  type        = string
}

variable "limit_unit" {
  description = "The unit of measurement used for the budget forecast, actual spend, or budget threshold"
  type        = string
  default     = "USD"
}

variable "time_unit" {
  description = "The length of time until a budget resets the actual and forecasted spend (MONTHLY, QUARTERLY, ANNUALLY, DAILY)"
  type        = string
  default     = "MONTHLY"
  validation {
    condition     = contains(["DAILY", "MONTHLY", "QUARTERLY", "ANNUALLY"], var.time_unit)
    error_message = "Valid values are DAILY, MONTHLY, QUARTERLY, or ANNUALLY"
  }
}

variable "time_period_start" {
  description = "The start of the time period covered by the budget (YYYY-MM-DD_HH:MM)"
  type        = string
  default     = null
}

variable "time_period_end" {
  description = "The end of the time period covered by the budget (YYYY-MM-DD_HH:MM)"
  type        = string
  default     = null
}

variable "cost_filters" {
  description = "Map of Cost Filters to use for the budget"
  type        = map(list(string))
  default     = {}
}

variable "cost_types" {
  description = "Cost types configuration"
  type = object({
    include_credit             = optional(bool, false)
    include_discount           = optional(bool, true)
    include_other_subscription = optional(bool, true)
    include_recurring          = optional(bool, true)
    include_refund             = optional(bool, false)
    include_subscription       = optional(bool, true)
    include_support            = optional(bool, true)
    include_tax                = optional(bool, true)
    include_upfront            = optional(bool, true)
    use_blended                = optional(bool, false)
  })
  default = {}
}

variable "notifications" {
  description = "List of budget notifications"
  type = list(object({
    comparison_operator        = string
    threshold                  = number
    threshold_type             = string
    notification_type          = string
    subscriber_email_addresses = optional(list(string), [])
    subscriber_sns_topic_arns  = optional(list(string), [])
  }))
  default = []
}

variable "auto_adjust_data" {
  description = "Auto adjust budget configuration"
  type = object({
    auto_adjust_type = string
    lookback_available_periods = optional(number)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

