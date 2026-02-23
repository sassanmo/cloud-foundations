locals {
  replication_group_id = "${var.project}-${var.environment}-${var.cache_suffix}"
  subnet_group_name    = "${local.replication_group_id}-subnet-group"
}

