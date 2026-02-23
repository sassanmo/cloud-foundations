locals {
  kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null
  key_name   = var.key_name != "" ? var.key_name : null
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null
}
