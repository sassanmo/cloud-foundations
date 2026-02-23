locals {
  kms_alias_name = "alias/${var.cluster_identifier}-aurora-key"

  # Initial KMS policy for key creation (will be replaced by specific policy)
  initial_kms_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "InitialKMSKeyPolicy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${var.partition}:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

