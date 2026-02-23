locals {
  function_name = "${var.project}-${var.environment}-${var.function_name_suffix}"
  role_name     = "${local.function_name}-role"
}

