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

variable "name" {
  description = "Name for the VPC endpoint"
  type        = string
  default     = "endpoint"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
}

variable "service_name" {
  description = "The service name for the VPC endpoint (e.g., com.amazonaws.region.s3)"
  type        = string
}

variable "vpc_endpoint_type" {
  description = "The VPC endpoint type"
  type        = string
  default     = "Gateway"

  validation {
    condition     = contains(["Gateway", "Interface", "GatewayLoadBalancer"], var.vpc_endpoint_type)
    error_message = "VPC endpoint type must be Gateway, Interface, or GatewayLoadBalancer."
  }
}

variable "route_table_ids" {
  description = "One or more route table IDs (for Gateway endpoints)"
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "The ID of one or more subnets (for Interface endpoints)"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "The ID of one or more security groups (for Interface endpoints)"
  type        = list(string)
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a default security group for Interface endpoints"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the VPC endpoint (when creating security group)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the VPC endpoint security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    self        = optional(bool)
    description = optional(string)
  }))
  default = [{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS inbound for VPC endpoint"
  }]
}

variable "security_group_egress_rules" {
  description = "List of egress rules for the VPC endpoint security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    self        = optional(bool)
    description = optional(string)
  }))
  default = [{
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }]
}

variable "policy" {
  description = "A policy to attach to the endpoint that controls access to the service"
  type        = string
  default     = null
}

variable "private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC"
  type        = bool
  default     = false
}

variable "auto_accept" {
  description = "Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account)"
  type        = bool
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
