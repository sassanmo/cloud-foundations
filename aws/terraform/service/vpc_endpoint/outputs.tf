output "vpc_endpoint_id" {
  description = "The ID of the VPC endpoint"
  value       = aws_vpc_endpoint.this.id
}

output "vpc_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) of the VPC endpoint"
  value       = aws_vpc_endpoint.this.arn
}

output "vpc_endpoint_state" {
  description = "The state of the VPC endpoint"
  value       = aws_vpc_endpoint.this.state
}

output "vpc_endpoint_prefix_list_id" {
  description = "The prefix list ID of the exposed AWS service"
  value       = aws_vpc_endpoint.this.prefix_list_id
}

output "vpc_endpoint_cidr_blocks" {
  description = "The list of CIDR blocks for the exposed AWS service"
  value       = aws_vpc_endpoint.this.cidr_blocks
}

output "vpc_endpoint_dns_entry" {
  description = "The DNS entries for the VPC Endpoint"
  value       = aws_vpc_endpoint.this.dns_entry
}

output "vpc_endpoint_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint"
  value       = aws_vpc_endpoint.this.network_interface_ids
}

output "endpoint_name" {
  description = "The name of the VPC endpoint"
  value       = local.endpoint_name
}

output "security_group_id" {
  description = "The ID of the created security group (if created)"
  value       = var.create_security_group && var.vpc_endpoint_type == "Interface" ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the created security group (if created)"
  value       = var.create_security_group && var.vpc_endpoint_type == "Interface" ? aws_security_group.this[0].arn : null
}
