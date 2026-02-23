locals {
  kms_key_id               = var.kms_key_id != "" ? var.kms_key_id : null
  parameter_group_name     = var.parameter_group_name != "" ? var.parameter_group_name : null
  final_snapshot_identifier = var.skip_final_snapshot ? null : (var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : "${var.identifier}-final-snapshot")
  db_name                  = var.db_name != "" ? var.db_name : null
}
