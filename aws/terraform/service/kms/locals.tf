locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  default_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  key_policy = var.policy != "" ? var.policy : local.default_policy
}
