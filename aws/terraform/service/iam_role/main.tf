resource "aws_iam_role" "this" {
  name                 = local.role_name
  assume_role_policy   = var.assume_role_policy
  description          = var.description
  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary

  tags = merge(
    var.tags,
    {
      Name        = local.role_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = local.role_name
  role = aws_iam_role.this.name

  tags = merge(
    var.tags,
    {
      Name        = local.role_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

