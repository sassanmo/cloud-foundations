locals {
  cluster_name      = "${var.project}-${var.environment}-${var.cluster_suffix}"
  cluster_role_name = "${local.cluster_name}-cluster-role"
}

