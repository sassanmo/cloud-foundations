module "kms" {
  source = "../../service/kms"

  account_id              = var.account_id
  region                  = var.region
  partition               = var.partition
  alias_name              = local.kms_alias_name
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  policy                  = local.secrets_manager_kms_policy

  tags = var.tags
}

module "secrets_manager" {
  source = "../../service/secrets_manager"

  for_each = var.secrets

  account_id    = var.account_id
  region        = var.region
  partition     = var.partition
  environment   = var.environment
  project       = var.project
  secret_suffix = each.key

  description             = each.value.description
  secret_string           = each.value.secret_string
  secret_key_value        = each.value.secret_key_value
  kms_key_id              = module.kms.key_id
  recovery_window_in_days = each.value.recovery_window_in_days
  rotation                = each.value.rotation
  policy                  = each.value.policy

  tags = merge(var.tags, each.value.tags)
}
