resource "aws_secretsmanager_secret" "this" {
  name        = local.secret_name
  description = var.description

  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, { Name = local.secret_name })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string != null ? var.secret_string : jsonencode(var.secret_key_value)
}

resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.rotation != null && var.rotation.enabled ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation.lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation.rotation_days
  }
}

resource "aws_secretsmanager_secret_policy" "this" {
  count = var.policy != null ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = var.policy
}

