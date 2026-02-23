resource "aws_docdb_cluster" "this" {
  cluster_identifier              = var.cluster_identifier
  engine_version                  = var.engine_version
  master_username                 = var.master_username
  master_password                 = var.master_password
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = var.db_subnet_group_name
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = local.kms_key_id
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = local.final_snapshot_identifier
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  db_cluster_parameter_group_name = local.cluster_parameter_group_name

  tags = var.tags
}

resource "aws_docdb_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class

  apply_immediately = var.apply_immediately

  tags = var.tags
}
