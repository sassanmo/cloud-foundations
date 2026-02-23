output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_id" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks.node_group_arns[0]
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks.node_group_statuses[0]
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.cluster_iam_role.arn
}

output "node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = module.node_group_iam_role.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch_logs.log_group_name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.cloudwatch_logs.log_group_arn
}

# VPC Outputs (only available when create_vpc = true)
output "vpc_id" {
  description = "ID of the VPC"
  value       = var.create_vpc ? module.vpc[0].vpc_id : null
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = var.create_vpc ? module.vpc[0].vpc_arn : null
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.create_vpc ? module.vpc[0].vpc_cidr_block : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = var.create_vpc ? module.vpc[0].public_subnet_ids : {}
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.create_vpc ? module.vpc[0].private_subnet_ids : {}
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_vpc ? module.vpc[0].internet_gateway_id : null
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.create_vpc ? module.vpc[0].nat_gateway_ids : {}
}

output "route_table_ids" {
  description = "IDs of the route tables"
  value       = var.create_vpc ? module.vpc[0].route_table_ids : {}
}
