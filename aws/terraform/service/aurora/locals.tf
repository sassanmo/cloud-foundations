locals {
  cluster_identifier = "${var.project}-${var.environment}-${var.cluster_suffix}"
  subnet_group_name  = "${local.cluster_identifier}-subnet-group"
}

