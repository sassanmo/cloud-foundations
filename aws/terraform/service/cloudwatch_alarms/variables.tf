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

variable "alarm_suffix" {
  description = "Suffix for the alarm name"
  type        = string
}

variable "alarm_description" {
  description = "Description of the alarm"
  type        = string
  default     = ""
}

variable "comparison_operator" {
  description = "Arithmetic operation to use when comparing statistic and threshold"
  type        = string

  validation {
    condition = contains([
      "GreaterThanOrEqualToThreshold",
      "GreaterThanThreshold",
      "LessThanThreshold",
      "LessThanOrEqualToThreshold",
      "LessThanLowerOrGreaterThanUpperThreshold",
      "LessThanLowerThreshold",
      "GreaterThanUpperThreshold"
    ], var.comparison_operator)
    error_message = "Invalid comparison operator."
  }
}

variable "evaluation_periods" {
  description = "Number of periods over which to compare the threshold"
  type        = number
}

variable "metric_name" {
  description = "Name of the metric"
  type        = string
}

variable "namespace" {
  description = "Namespace for the metric"
  type        = string
}

variable "period" {
  description = "Period in seconds over which the statistic is applied"
  type        = number
  default     = 300
}

variable "statistic" {
  description = "Statistic to apply to the alarm's metric"
  type        = string
  default     = "Average"

  validation {
    condition     = contains(["SampleCount", "Average", "Sum", "Minimum", "Maximum"], var.statistic)
    error_message = "Statistic must be one of: SampleCount, Average, Sum, Minimum, Maximum."
  }
}

variable "threshold" {
  description = "Value against which the statistic is compared"
  type        = number
}

variable "treat_missing_data" {
  description = "How to treat missing data"
  type        = string
  default     = "missing"

  validation {
    condition     = contains(["missing", "notBreaching", "breaching", "ignore"], var.treat_missing_data)
    error_message = "treat_missing_data must be one of: missing, notBreaching, breaching, ignore."
  }
}

variable "datapoints_to_alarm" {
  description = "Number of datapoints that must be breaching to trigger the alarm"
  type        = number
  default     = null
}

variable "dimensions" {
  description = "Dimensions for the metric"
  type        = map(string)
  default     = {}
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm transitions to ALARM state"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm transitions to OK state"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs to notify when alarm transitions to INSUFFICIENT_DATA state"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

