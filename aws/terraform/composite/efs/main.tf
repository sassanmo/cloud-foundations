module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.efs_kms_policy

  tags = var.tags
}

module "efs" {
  source = "../../service/efs"

  account_id                      = var.account_id
  region                          = var.region
  partition                       = var.partition
  creation_token                  = var.creation_token
  performance_mode               = var.performance_mode
  throughput_mode                = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  encrypted                      = true
  kms_key_id                    = module.kms.key_arn

  mount_targets = var.mount_targets
  access_points = var.access_points

  backup_policy_status = var.backup_policy_status

  tags = var.tags
}
