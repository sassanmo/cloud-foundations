module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.rds_kms_policy

  tags = var.tags
}

module "rds" {
  source = "../../service/rds"

  account_id              = var.account_id
  region                  = var.region
  partition               = var.partition
  identifier              = var.identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  username                = var.username
  password                = var.password
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.vpc_security_group_ids
  kms_key_id              = module.kms.key_arn
  storage_encrypted       = true
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection

  tags = var.tags
}
