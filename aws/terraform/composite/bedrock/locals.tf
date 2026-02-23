locals {
  # KMS alias name based on environment and project
  kms_alias_name = "alias/${var.project}-${var.environment}-bedrock-key"

  # Resource names with consistent naming convention
  agent_name          = var.agent_name != null ? "${var.project}-${var.environment}-${var.agent_name}" : null
  knowledge_base_name = var.knowledge_base_name != null ? "${var.project}-${var.environment}-${var.knowledge_base_name}" : null
  guardrail_name      = var.guardrail_name != null ? "${var.project}-${var.environment}-${var.guardrail_name}" : null

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

