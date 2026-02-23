variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "config_bucket" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
}

