locals {
  kms_alias_name = "alias/${var.creation_token}-efs-key"

  efs_kms_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "EFSKMSKeyPolicy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${var.partition}:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EFS Service"
        Effect = "Allow"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "elasticfilesystem.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

