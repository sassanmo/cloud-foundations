locals {
  kms_key_id                   = var.kms_key_id != "" ? var.kms_key_id : null
  cluster_parameter_group_name = var.cluster_parameter_group_name != "" ? var.cluster_parameter_group_name : null
  final_snapshot_identifier    = var.skip_final_snapshot ? null : (var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : "${var.cluster_identifier}-final-snapshot")
}
