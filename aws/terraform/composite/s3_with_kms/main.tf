module "kms" {
  source = "../../service/kms"

  alias_name              = local.kms_alias_name
  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = var.tags
}

module "s3" {
  source = "../../service/s3"

  bucket_name        = var.bucket_name
  versioning_enabled = var.versioning_enabled
  force_destroy      = var.force_destroy
  kms_key_arn        = module.kms.key_arn
  lifecycle_rules    = var.lifecycle_rules

  tags = var.tags
}
