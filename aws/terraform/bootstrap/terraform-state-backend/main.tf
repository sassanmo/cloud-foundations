# Bootstrap Terraform State Backend Infrastructure
# ============================================
#
# This configuration creates the S3 bucket, KMS key, and DynamoDB table needed for Terraform remote state.
# Run this ONCE with local state, then optionally migrate your state to the created backend.
locals {
  bucket_name = "${var.account_id}-terraform-states-${var.environment}"
  kms_alias   = "alias/terraform-state-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Purpose     = "terraform-state-backend"
      ManagedBy   = "Terraform"
    }
  )
}

# KMS Key for encrypting Terraform state files
module "kms" {
  source = "../../service/kms"

  region                  = var.region
  account_id              = var.account_id
  partition               = var.partition
  alias_name              = local.kms_alias
  description             = "KMS key for encrypting Terraform state files"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-state-${var.environment}"
    }
  )
}

# S3 Bucket for Terraform State Storage
module "s3" {
  source = "../../service/s3"

  region             = var.region
  account_id         = var.account_id
  partition          = var.partition
  bucket_name        = local.bucket_name
  versioning_enabled = true
  force_destroy      = false
  kms_key_arn        = module.kms.key_arn

  # Enable access logging
  enable_logging        = var.enable_logging
  logging_target_bucket = var.logging_bucket
  logging_target_prefix = "logs/"

  lifecycle_rules = [
    {
      id                                 = "expire-old-versions"
      enabled                            = true
      noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
    },
    {
      id      = "expire-delete-markers"
      enabled = true
      # expiration_days and noncurrent_version_expiration_days are optional
    }
  ]

  tags = merge(
    local.common_tags,
    {
      Name = local.bucket_name
    }
  )
}

# DynamoDB Table for State Locking
module "dynamodb" {
  source = "../../service/dynamo_db"

  region                 = var.region
  account_id             = var.account_id
  partition              = var.partition
  table_name             = "terraform-state-lock-${var.environment}"
  billing_mode           = "PAY_PER_REQUEST"
  hash_key               = "LockID"
  hash_key_type          = "S"
  enable_encryption      = true
  kms_key_arn            = module.kms.key_arn
  point_in_time_recovery = true

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-state-lock-${var.environment}"
    }
  )
}


# Bucket policy to enforce encryption and secure access
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = module.s3.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnencryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${module.s3.bucket_arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.s3.bucket_arn,
          "${module.s3.bucket_arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# ============================================
# IAM Policies for State Access Control
# ============================================

# IAM Policy for Full Terraform State Access (Admin/CI-CD)
resource "aws_iam_policy" "terraform_state_admin" {
  count = var.create_iam_policies ? 1 : 0

  name        = "TerraformStateAdmin-${var.environment}"
  description = "Full access to Terraform state bucket and DynamoDB table for ${var.environment}"
  path        = "/terraform/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = module.s3.bucket_arn
      },
      {
        Sid    = "S3ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${module.s3.bucket_arn}/*"
      },
      {
        Sid    = "DynamoDBLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = module.dynamodb.table_arn
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = module.kms.key_arn
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy for Read-Only Terraform State Access (Developers)
resource "aws_iam_policy" "terraform_state_read_only" {
  count = var.create_iam_policies ? 1 : 0

  name        = "TerraformStateReadOnly-${var.environment}"
  description = "Read-only access to Terraform state for ${var.environment}"
  path        = "/terraform/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateListAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = module.s3.bucket_arn
      },
      {
        Sid    = "S3ObjectReadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${module.s3.bucket_arn}/*"
      },
      {
        Sid    = "DynamoDBReadAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:DescribeTable"
        ]
        Resource = module.dynamodb.table_arn
      },
      {
        Sid    = "KMSDecryptAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = module.kms.key_arn
      }
    ]
  })

  tags = local.common_tags
}

# Attach policies to admin roles
resource "aws_iam_role_policy_attachment" "admin_attach" {
  count = var.create_iam_policies && length(var.terraform_admin_role_arns) > 0 ? length(var.terraform_admin_role_arns) : 0

  role       = element(split("/", var.terraform_admin_role_arns[count.index]), length(split("/", var.terraform_admin_role_arns[count.index])) - 1)
  policy_arn = aws_iam_policy.terraform_state_admin[0].arn
}

# Attach policies to read-only roles
resource "aws_iam_role_policy_attachment" "readonly_attach" {
  count = var.create_iam_policies && length(var.terraform_read_only_role_arns) > 0 ? length(var.terraform_read_only_role_arns) : 0

  role       = element(split("/", var.terraform_read_only_role_arns[count.index]), length(split("/", var.terraform_read_only_role_arns[count.index])) - 1)
  policy_arn = aws_iam_policy.terraform_state_read_only[0].arn
}

# ============================================
# CloudTrail for State Bucket Access Logging
# ============================================

# CloudTrail S3 Bucket
module "cloudtrail_bucket" {
  count = var.enable_cloudtrail ? 1 : 0

  source = "../../service/s3"

  region             = var.region
  account_id         = var.account_id
  partition          = var.partition
  bucket_name        = var.cloudtrail_bucket_name != "" ? var.cloudtrail_bucket_name : "${var.account_id}-terraform-state-cloudtrail-${var.environment}"
  versioning_enabled = true
  force_destroy      = false
  # Use AES256 encryption (no KMS key specified)

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-state-cloudtrail-${var.environment}"
    }
  )
}


# CloudTrail S3 Bucket Policy
resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = module.cloudtrail_bucket[0].bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = module.cloudtrail_bucket[0].bucket_arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${module.cloudtrail_bucket[0].bucket_arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.cloudtrail_bucket[0].bucket_arn,
          "${module.cloudtrail_bucket[0].bucket_arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# CloudTrail Trail
resource "aws_cloudtrail" "terraform_state" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "terraform-state-${var.environment}"
  s3_bucket_name                = module.cloudtrail_bucket[0].bucket_id
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${module.s3.bucket_arn}/*"
      ]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::DynamoDB::Table"
      values = [
        module.dynamodb.table_arn
      ]
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-state-${var.environment}"
    }
  )

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}

# ============================================
# S3 Replication for Disaster Recovery
# ============================================

# KMS Key in replication region
module "kms_replication" {
  count = var.enable_replication ? 1 : 0

  source = "../../service/kms"

  providers = {
    aws = aws.replication
  }

  region                  = var.replication_region
  account_id              = var.account_id
  partition               = var.partition
  alias_name              = "alias/terraform-state-replication-${var.environment}"
  description             = "KMS key for Terraform state replication in ${var.replication_region}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-state-replication-${var.environment}"
    }
  )
}


# Replication destination bucket
module "replication_bucket" {
  count = var.enable_replication ? 1 : 0

  source = "../../service/s3"

  providers = {
    aws = aws.replication
  }

  region             = var.replication_region
  account_id         = var.account_id
  partition          = var.partition
  bucket_name        = "${var.account_id}-terraform-states-${var.environment}-replica"
  versioning_enabled = true
  force_destroy      = false
  kms_key_arn        = module.kms_replication[0].key_arn

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-state-replication-${var.environment}"
    }
  )
}


# IAM Role for S3 Replication
resource "aws_iam_role" "replication" {
  count = var.enable_replication ? 1 : 0

  name = "terraform-state-replication-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "replication" {
  count = var.enable_replication ? 1 : 0

  name = "terraform-state-replication-${var.environment}"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          module.s3.bucket_arn
        ]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = [
          "${module.s3.bucket_arn}/*"
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = [
          "${module.replication_bucket[0].bucket_arn}/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Resource = [
          module.kms.key_arn
        ]
        Condition = {
          StringLike = {
            "kms:ViaService" = "s3.${var.region}.amazonaws.com"
          }
        }
      },
      {
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Effect = "Allow"
        Resource = [
          module.kms_replication[0].key_arn
        ]
        Condition = {
          StringLike = {
            "kms:ViaService" = "s3.${var.replication_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# S3 Replication Configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  count = var.enable_replication ? 1 : 0

  bucket = module.s3.bucket_id
  role   = aws_iam_role.replication[0].arn

  rule {
    id     = "replicate-terraform-state"
    status = "Enabled"

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    filter {}

    destination {
      bucket        = module.replication_bucket[0].bucket_arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = module.kms_replication[0].key_arn
      }

      replication_time {
        status = "Enabled"
        time {
          minutes = 15
        }
      }

      metrics {
        status = "Enabled"
        event_threshold {
          minutes = 15
        }
      }
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}
