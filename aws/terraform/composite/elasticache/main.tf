module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.elasticache_kms_policy

  tags = var.tags
}

module "elasticache" {
  source = "../../service/elasticache"

  account_id           = var.account_id
  region               = var.region
  partition            = var.partition
  cluster_id           = var.cluster_id
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = var.subnet_group_name
  security_group_ids   = var.security_group_ids

  # Enable encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled
  kms_key_id                = module.kms.key_arn

  # Backup configuration
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = var.snapshot_window
  maintenance_window      = var.maintenance_window

  apply_immediately       = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  notification_topic_arn  = var.notification_topic_arn

  tags = var.tags
}
