module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.initial_kms_policy

  tags = var.tags
}

module "aurora" {
  source = "../../service/aurora"

  account_id                      = var.account_id
  region                          = var.region
  partition                       = var.partition
  cluster_identifier              = var.cluster_identifier
  engine                          = var.engine
  engine_version                  = var.engine_version
  engine_mode                     = var.engine_mode
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  instance_class                  = var.instance_class
  instance_count                  = var.instance_count
  port                           = var.port
  subnet_ids                     = var.subnet_ids
  vpc_security_group_ids         = var.vpc_security_group_ids
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  backup_retention_period        = var.backup_retention_period
  preferred_backup_window        = var.preferred_backup_window
  preferred_maintenance_window   = var.preferred_maintenance_window
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  deletion_protection            = var.deletion_protection
  skip_final_snapshot           = var.skip_final_snapshot
  apply_immediately             = var.apply_immediately
  publicly_accessible           = var.publicly_accessible
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration
  kms_key_id                    = module.kms.key_arn

  tags = var.tags
}
