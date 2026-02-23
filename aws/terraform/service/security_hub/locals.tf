locals {
  action_target_name = var.action_target_name != null ? "${var.project}-${var.environment}-${var.action_target_name}" : null
}

