resource "aws_cognito_user_pool" "this" {
  name = local.user_pool_name

  alias_attributes         = var.alias_attributes
  auto_verified_attributes = var.auto_verified_attributes
  username_attributes      = var.username_attributes

  dynamic "password_policy" {
    for_each = var.password_policy != null ? [var.password_policy] : []
    content {
      minimum_length                   = password_policy.value.minimum_length
      require_lowercase                = password_policy.value.require_lowercase
      require_numbers                  = password_policy.value.require_numbers
      require_symbols                  = password_policy.value.require_symbols
      require_uppercase                = password_policy.value.require_uppercase
      temporary_password_validity_days = password_policy.value.temporary_password_validity_days
    }
  }

  dynamic "schema" {
    for_each = var.schemas
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = schema.value.developer_only_attribute
      mutable                  = schema.value.mutable
      required                 = schema.value.required

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [schema.value.string_attribute_constraints] : []
        content {
          min_length = string_attribute_constraints.value.min_length
          max_length = string_attribute_constraints.value.max_length
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [schema.value.number_attribute_constraints] : []
        content {
          min_value = number_attribute_constraints.value.min_value
          max_value = number_attribute_constraints.value.max_value
        }
      }
    }
  }

  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "account_recovery_setting" {
    for_each = var.account_recovery_setting != null ? [var.account_recovery_setting] : []
    content {
      dynamic "recovery_mechanism" {
        for_each = account_recovery_setting.value.recovery_mechanisms
        content {
          name     = recovery_mechanism.value.name
          priority = recovery_mechanism.value.priority
        }
      }
    }
  }

  tags = merge(var.tags, { Name = local.user_pool_name })
}

resource "aws_cognito_user_pool_client" "this" {
  for_each = var.clients

  name         = "${local.user_pool_name}-${each.key}"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = each.value.generate_secret
  refresh_token_validity               = each.value.refresh_token_validity
  access_token_validity                = each.value.access_token_validity
  id_token_validity                    = each.value.id_token_validity
  token_validity_units {
    refresh_token = each.value.token_validity_units.refresh_token
    access_token  = each.value.token_validity_units.access_token
    id_token      = each.value.token_validity_units.id_token
  }

  explicit_auth_flows                  = each.value.explicit_auth_flows
  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  callback_urls                        = each.value.callback_urls
  logout_urls                          = each.value.logout_urls
  supported_identity_providers         = each.value.supported_identity_providers

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "this" {
  count = var.domain != null ? 1 : 0

  domain       = var.domain
  user_pool_id = aws_cognito_user_pool.this.id
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
