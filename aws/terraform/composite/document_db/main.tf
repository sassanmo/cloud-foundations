module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.docdb_kms_policy

  tags = var.tags
}

resource "aws_kms_key_policy" "docdb_specific" {
  key_id = module.kms.key_id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "DocumentDBSpecificKMSKeyPolicy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${var.partition}:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = module.kms.key_arn
      },
      {
        Sid    = "Allow RDS Service for DocumentDB"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = module.kms.key_arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "rds.${var.region}.amazonaws.com"
          }
          StringLike = {
            "kms:EncryptionContext:aws:docdb:cluster-id" = var.cluster_identifier
          }
        }
      }
    ]
  })
}

module "document_db" {
  source = "../../service/document_db"

  account_id                      = var.account_id
  region                          = var.region
  partition                       = var.partition
  cluster_identifier              = var.cluster_identifier
  engine_version                  = var.engine_version
  master_username                 = var.master_username
  master_password                 = var.master_password
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = var.db_subnet_group_name
  storage_encrypted               = true
  kms_key_id                      = module.kms.key_arn
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  instance_count                  = var.instance_count
  instance_class                  = var.instance_class

  tags = var.tags
}
