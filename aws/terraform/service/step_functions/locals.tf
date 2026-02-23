locals {
  state_machine_name = "${var.project}-${var.environment}-${var.state_machine_suffix}"
  role_name          = "${local.state_machine_name}-role"
}

