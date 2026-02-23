locals {
  kms_alias_name = var.kms_alias_name != "" ? var.kms_alias_name : "alias/${var.identifier}-key"
}
