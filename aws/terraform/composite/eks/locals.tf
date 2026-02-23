locals {
  cluster_role_name     = "${var.cluster_name}-cluster-role"
  node_group_role_name  = "${var.cluster_name}-node-group-role"
  log_group_name        = "/aws/eks/${var.cluster_name}/cluster"

  # Subnet logic - use created VPC subnets if VPC is created, otherwise use provided subnet IDs
  vpc_subnet_ids = var.create_vpc ? concat(
    values(module.vpc[0].public_subnet_ids),
    values(module.vpc[0].private_subnet_ids)
  ) : []

  # Use VPC subnets when create_vpc=true, otherwise fall back to provided subnet_ids
  subnet_ids = var.create_vpc ? local.vpc_subnet_ids : var.subnet_ids

  # Node subnets - prefer private subnets for nodes, fallback to all subnets
  vpc_node_subnet_ids = var.create_vpc ? (
    length(values(module.vpc[0].private_subnet_ids)) > 0 ?
    values(module.vpc[0].private_subnet_ids) :
    values(module.vpc[0].public_subnet_ids)
  ) : []

  # Use VPC node subnets when create_vpc=true, otherwise fall back to provided node_subnet_ids
  node_subnet_ids = var.create_vpc ? local.vpc_node_subnet_ids : var.node_subnet_ids

  # Security group logic - when creating VPC, use empty list to let EKS create its own security groups
  # When not creating VPC, use user-provided security groups
  cluster_security_group_ids = var.create_vpc ? [] : var.cluster_security_group_ids

  # Access control logic - when creating VPC with private subnets, prefer private access
  endpoint_private_access = var.create_vpc && length(var.private_subnets) > 0 ? true : var.endpoint_private_access
  endpoint_public_access = var.create_vpc && length(var.private_subnets) > 0 ? false : var.endpoint_public_access

  eks_cluster_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  eks_node_group_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  eks_cluster_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]

  eks_node_group_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}
