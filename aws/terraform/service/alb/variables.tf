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

variable "alb_suffix" {
  description = "Suffix for the ALB name"
  type        = string
  default     = "alb"
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target groups"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "enable_waf_fail_open" {
  description = "Enable WAF fail open"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Connection idle timeout in seconds"
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid header fields"
  type        = bool
  default     = true
}

variable "access_logs_enabled" {
  description = "Enable access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = ""
}

variable "target_groups" {
  description = "Map of target groups"
  type = map(object({
    port                 = number
    protocol             = optional(string, "HTTP")
    target_type          = optional(string, "ip")
    deregistration_delay = optional(number, 300)
    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      timeout             = optional(number, 5)
      interval            = optional(number, 30)
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200")
    }))
    stickiness = optional(object({
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
      enabled         = optional(bool, true)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "listeners" {
  description = "Map of listeners"
  type = map(object({
    port            = number
    protocol        = string
    ssl_policy      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    certificate_arn = optional(string)
    default_action = object({
      type             = string
      target_group_key = optional(string)
      redirect = optional(object({
        port        = string
        protocol    = string
        status_code = string
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
    })
  }))
  default = {}
}

variable "additional_certificates" {
  description = "Map of additional certificates for listeners"
  type = map(object({
    listener_key    = string
    certificate_arn = string
  }))
  default = {}
}

variable "listener_rules" {
  description = "Map of listener rules"
  type = map(object({
    listener_key = string
    priority     = number
    action = object({
      type             = string
      target_group_key = optional(string)
      redirect = optional(object({
        port        = optional(string, "#{port}")
        protocol    = optional(string, "#{protocol}")
        status_code = string
        host        = optional(string, "#{host}")
        path        = optional(string, "/#{path}")
        query       = optional(string, "#{query}")
      }))
    })
    conditions = list(object({
      path_pattern        = optional(list(string))
      host_header         = optional(list(string))
      http_request_method = optional(list(string))
      http_header = optional(object({
        name   = string
        values = list(string)
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
