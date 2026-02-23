locals {
  endpoint_name = "${var.project}-${var.environment}-${var.name}"

  # Determine which security group IDs to use based on configuration
  security_group_ids = var.vpc_endpoint_type == "Interface" ? concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.security_group_ids != null ? var.security_group_ids : []
  ) : null
}
