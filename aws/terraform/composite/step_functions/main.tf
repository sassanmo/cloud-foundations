module "iam_role" {
  source = "../../service/iam_role"

  name               = local.step_functions_role_name
  assume_role_policy = local.step_functions_assume_role_policy
  policy_arns       = local.step_functions_policy_arns

  tags = var.tags
}

module "cloudwatch_logs" {
  source = "../../service/cloudwatch_logs"

  log_group_name        = local.log_group_name
  retention_in_days     = var.log_retention_days
  kms_key_id           = var.log_group_kms_key_id

  tags = var.tags
}

module "step_functions" {
  source = "../../service/step_functions"

  name       = var.state_machine_name
  role_arn   = module.iam_role.arn
  definition = var.definition
  type       = var.type

  logging_configuration = {
    log_destination        = "${module.cloudwatch_logs.log_group_arn}:*"
    include_execution_data = var.include_execution_data
    level                 = var.log_level
  }

  tracing_configuration = var.tracing_enabled ? {
    enabled = true
  } : null

  tags = var.tags

  depends_on = [module.cloudwatch_logs]
}


