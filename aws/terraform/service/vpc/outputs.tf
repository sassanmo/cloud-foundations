output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "database_subnet_ids" {
  description = "Map of database subnet IDs"
  value       = { for k, v in aws_subnet.database : k => v.id }
}

output "public_subnet_arns" {
  description = "Map of public subnet ARNs"
  value       = { for k, v in aws_subnet.public : k => v.arn }
}

output "private_subnet_arns" {
  description = "Map of private subnet ARNs"
  value       = { for k, v in aws_subnet.private : k => v.arn }
}

output "database_subnet_arns" {
  description = "Map of database subnet ARNs"
  value       = { for k, v in aws_subnet.database : k => v.arn }
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs"
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "nat_gateway_public_ips" {
  description = "Map of NAT Gateway public IPs"
  value       = { for k, v in aws_eip.nat : k => v.public_ip }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

