module "vpc" {
  count = var.create_vpc ? 1 : 0
  source = "../../service/vpc"

  environment = var.environment
  project     = var.project
  vpc_suffix  = "${var.cluster_name}-vpc"
  vpc_cidr    = var.vpc_cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  tags = var.tags
}

module "cluster_iam_role" {
  source = "../../service/iam_role"

  name               = local.cluster_role_name
  assume_role_policy = local.eks_cluster_assume_role_policy
  policy_arns       = local.eks_cluster_policy_arns

  tags = var.tags
}

module "node_group_iam_role" {
  source = "../../service/iam_role"

  name               = local.node_group_role_name
  assume_role_policy = local.eks_node_group_assume_role_policy
  policy_arns       = local.eks_node_group_policy_arns

  tags = var.tags
}

module "cloudwatch_logs" {
  source = "../../service/cloudwatch_logs"

  log_group_name        = local.log_group_name
  retention_in_days     = var.log_retention_days
  kms_key_id           = var.log_group_kms_key_id

  tags = var.tags
}

module "eks" {
  source = "../../service/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  role_arn       = module.cluster_iam_role.arn

  vpc_config = {
    subnet_ids              = local.subnet_ids
    endpoint_private_access = local.endpoint_private_access
    endpoint_public_access  = local.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = local.cluster_security_group_ids
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  node_groups = [
    {
      node_group_name = var.node_group_name
      node_role_arn   = module.node_group_iam_role.arn
      subnet_ids      = local.node_subnet_ids

      scaling_config = {
        desired_size = var.desired_capacity
        max_size     = var.max_capacity
        min_size     = var.min_capacity
      }

      update_config = {
        max_unavailable_percentage = var.max_unavailable_percentage
      }

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
      ami_type      = var.ami_type
      disk_size     = var.disk_size

      remote_access = var.key_name != null ? {
        ec2_ssh_key               = var.key_name
        source_security_group_ids = var.source_security_group_ids
      } : null

      labels = var.node_labels
      taints = var.node_taints
    }
  ]

  addons = var.addons

  tags = var.tags

  depends_on = [module.cloudwatch_logs]
}
