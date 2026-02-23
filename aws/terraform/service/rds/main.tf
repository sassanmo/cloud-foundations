resource "aws_db_instance" "this" {
  identifier                = var.identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  allocated_storage         = var.allocated_storage
  max_allocated_storage     = var.max_allocated_storage
  db_name                   = local.db_name
  username                  = var.username
  password                  = var.password
  port                      = var.port
  vpc_security_group_ids    = var.vpc_security_group_ids
  db_subnet_group_name      = var.db_subnet_group_name
  multi_az                  = var.multi_az
  storage_encrypted         = var.storage_encrypted
  kms_key_id                = local.kms_key_id
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier
  parameter_group_name      = local.parameter_group_name
  apply_immediately         = var.apply_immediately
  storage_type              = "gp3"
  publicly_accessible       = false
  auto_minor_version_upgrade = true

  tags = var.tags
}

