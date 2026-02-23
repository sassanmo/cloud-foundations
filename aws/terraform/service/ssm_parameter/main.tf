resource "aws_ssm_parameter" "this" {
  name            = local.parameter_name
  description     = var.description
  type            = var.type
  value           = var.value
  tier            = var.tier
  key_id          = var.type == "SecureString" ? var.kms_key_id : null
  allowed_pattern = var.allowed_pattern
  data_type       = var.data_type
  overwrite       = var.overwrite

  tags = merge(
    var.tags,
    {
      Name        = local.parameter_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

