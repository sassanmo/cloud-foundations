locals {
  kms_alias_name = "alias/${var.project}-${var.environment}-cloudwatch-logs-key"

  cloudwatch_logs_kms_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "CloudWatchLogsKMSKeyPolicy"
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
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:${var.partition}:logs:${var.region}:${var.account_id}:log-group:/${var.project}/${var.environment}/${var.log_group_name}"
          }
        }
      }
    ]
  })
}

