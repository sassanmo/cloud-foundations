# Optional security group for Interface endpoints
resource "aws_security_group" "this" {
  count = var.create_security_group && var.vpc_endpoint_type == "Interface" ? 1 : 0

  name_prefix = "${local.endpoint_name}-"
  vpc_id      = var.vpc_id
  description = "Security group for ${local.endpoint_name} VPC endpoint"

  tags = merge(
    var.tags,
    {
      Name        = "${local.endpoint_name}-sg"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Dynamic security group ingress rules
resource "aws_security_group_rule" "ingress" {
  for_each = var.create_security_group && var.vpc_endpoint_type == "Interface" ? {
    for idx, rule in var.security_group_ingress_rules : idx => rule
  } : {}

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks != null ? each.value.cidr_blocks : var.allowed_cidr_blocks
  self              = each.value.self
  security_group_id = aws_security_group.this[0].id
  description       = each.value.description
}

# Dynamic security group egress rules
resource "aws_security_group_rule" "egress" {
  for_each = var.create_security_group && var.vpc_endpoint_type == "Interface" ? {
    for idx, rule in var.security_group_egress_rules : idx => rule
  } : {}

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks != null ? each.value.cidr_blocks : var.allowed_cidr_blocks
  self              = each.value.self
  security_group_id = aws_security_group.this[0].id
  description       = each.value.description
}

resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = var.vpc_endpoint_type
  route_table_ids     = var.route_table_ids
  subnet_ids          = var.subnet_ids
  security_group_ids  = local.security_group_ids
  policy              = var.policy
  private_dns_enabled = var.private_dns_enabled
  auto_accept         = var.auto_accept

  tags = merge(
    var.tags,
    {
      Name        = local.endpoint_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}
