module "kms" {
  source = "../../service/kms"

  account_id              = var.account_id
  region                  = var.region
  partition               = var.partition
  alias_name              = local.kms_alias_name
  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = local.s3_kms_policy

  tags = var.tags
}

module "s3" {
  source = "../../service/s3"

  account_id         = var.account_id
  region             = var.region
  partition          = var.partition
  bucket_name        = var.bucket_name
  versioning_enabled = var.versioning_enabled
  force_destroy      = var.force_destroy
  kms_key_arn        = module.kms.key_arn
  lifecycle_rules    = var.lifecycle_rules

  # Logging configuration
  enable_logging        = var.enable_logging
  logging_target_bucket = var.logging_target_bucket
  logging_target_prefix = var.logging_target_prefix

  tags = var.tags
}
