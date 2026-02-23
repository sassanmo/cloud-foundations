locals {
  task_family          = "${var.project}-${var.environment}-${var.app_suffix}"
  service_name         = "${var.project}-${var.environment}-${var.app_suffix}"
  execution_role_name  = "${var.project}-${var.environment}-${var.app_suffix}-execution-role"
  log_group_name       = "/ecs/${var.project}-${var.environment}/${var.app_suffix}"
}

