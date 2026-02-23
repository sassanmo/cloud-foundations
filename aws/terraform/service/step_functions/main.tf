resource "aws_sfn_state_machine" "this" {
  name     = local.state_machine_name
  role_arn = var.create_role ? aws_iam_role.step_functions[0].arn : var.existing_role_arn

  definition = var.definition

  type = var.state_machine_type

  dynamic "logging_configuration" {
    for_each = var.logging_configuration != null ? [var.logging_configuration] : []
    content {
      log_destination        = "${logging_configuration.value.log_group_arn}:*"
      include_execution_data = logging_configuration.value.include_execution_data
      level                  = logging_configuration.value.level
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.enable_xray_tracing ? [1] : []
    content {
      enabled = true
    }
  }

  tags = merge(var.tags, { Name = local.state_machine_name })
}

resource "aws_iam_role" "step_functions" {
  count = var.create_role ? 1 : 0

  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.step_functions_assume_role[0].json

  tags = merge(var.tags, { Name = local.role_name })
}

data "aws_iam_policy_document" "step_functions_assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "step_functions_cloudwatch" {
  count = var.create_role && var.logging_configuration != null ? 1 : 0

  name   = "${local.role_name}-cloudwatch"
  role   = aws_iam_role.step_functions[0].id
  policy = data.aws_iam_policy_document.cloudwatch_logs[0].json
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  count = var.create_role && var.logging_configuration != null ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "step_functions_xray" {
  count = var.create_role && var.enable_xray_tracing ? 1 : 0

  name   = "${local.role_name}-xray"
  role   = aws_iam_role.step_functions[0].id
  policy = data.aws_iam_policy_document.xray[0].json
}

data "aws_iam_policy_document" "xray" {
  count = var.create_role && var.enable_xray_tracing ? 1 : 0

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "step_functions_custom" {
  count = var.create_role && var.custom_policy_json != "" ? 1 : 0

  name   = "${local.role_name}-custom"
  role   = aws_iam_role.step_functions[0].id
  policy = var.custom_policy_json
}

resource "aws_cloudwatch_log_group" "step_functions" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/vendedlogs/states/${local.state_machine_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(var.tags, { Name = "/aws/vendedlogs/states/${local.state_machine_name}" })
}

