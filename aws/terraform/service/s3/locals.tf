locals {
  encryption_algorithm = var.kms_key_arn != "" ? "aws:kms" : "AES256"
  kms_master_key_id    = var.kms_key_arn != "" ? var.kms_key_arn : null
}
