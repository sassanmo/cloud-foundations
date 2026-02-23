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

variable "pool_suffix" {
  description = "Suffix for the user pool name"
  type        = string
  default     = "users"
}

variable "alias_attributes" {
  description = "Attributes supported as an alias for this user pool"
  type        = list(string)
  default     = ["email", "preferred_username"]
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "username_attributes" {
  description = "Whether email addresses or phone numbers can be used as usernames"
  type        = list(string)
  default     = ["email"]
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length                   = optional(number, 8)
    require_lowercase                = optional(bool, true)
    require_numbers                  = optional(bool, true)
    require_symbols                  = optional(bool, true)
    require_uppercase                = optional(bool, true)
    temporary_password_validity_days = optional(number, 7)
  })
  default = null
}

variable "schemas" {
  description = "List of schema attributes"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, true)
    required                 = optional(bool, false)
    string_attribute_constraints = optional(object({
      min_length = optional(number, 0)
      max_length = optional(number, 2048)
    }), null)
    number_attribute_constraints = optional(object({
      min_value = optional(number)
      max_value = optional(number)
    }), null)
  }))
  default = []
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, or OPTIONAL)"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL."
  }
}

variable "account_recovery_setting" {
  description = "Account recovery configuration"
  type = object({
    recovery_mechanisms = list(object({
      name     = string
      priority = number
    }))
  })
  default = null
}

variable "clients" {
  description = "Map of user pool clients"
  type = map(object({
    generate_secret                      = optional(bool, false)
    refresh_token_validity               = optional(number, 30)
    access_token_validity                = optional(number, 60)
    id_token_validity                    = optional(number, 60)
    token_validity_units = optional(object({
      refresh_token = optional(string, "days")
      access_token  = optional(string, "minutes")
      id_token      = optional(string, "minutes")
    }), {})
    explicit_auth_flows                  = optional(list(string), ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"])
    allowed_oauth_flows                  = optional(list(string), [])
    allowed_oauth_flows_user_pool_client = optional(bool, false)
    allowed_oauth_scopes                 = optional(list(string), [])
    callback_urls                        = optional(list(string), [])
    logout_urls                          = optional(list(string), [])
    supported_identity_providers         = optional(list(string), ["COGNITO"])
  }))
  default = {}
}

variable "domain" {
  description = "Domain prefix for the Cognito user pool"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

