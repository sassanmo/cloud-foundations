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

variable "name" {
  description = "Name of the EC2 instance."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the instance."
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key pair name for SSH access."
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance."
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root EBS volume."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Enable encryption on the root EBS volume."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID to use for root EBS volume encryption."
  type        = string
  default     = ""
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data to provide when launching the instance."
  type        = string
  default     = ""
}

variable "metadata_options" {
  description = "Metadata options (IMDSv2 settings)."
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
