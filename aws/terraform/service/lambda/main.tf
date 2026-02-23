resource "aws_lambda_function" "this" {
  function_name = local.function_name
  role          = var.create_role ? aws_iam_role.lambda[0].arn : var.existing_role_arn

  filename         = var.filename
  source_code_hash = var.source_code_hash
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version

  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  architectures = var.architectures

  publish = var.publish

  layers = var.layers

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  kms_key_arn = var.kms_key_arn

  reserved_concurrent_executions = var.reserved_concurrent_executions

  tags = merge(var.tags, { Name = local.function_name })
}

resource "aws_iam_role" "lambda" {
  count = var.create_role ? 1 : 0

  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json

  tags = merge(var.tags, { Name = local.role_name })
}

data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:${var.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count = var.create_role && var.vpc_subnet_ids != null ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:${var.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_custom" {
  count = var.create_role && var.custom_policy_json != "" ? 1 : 0

  name   = "${local.role_name}-custom"
  role   = aws_iam_role.lambda[0].id
  policy = var.custom_policy_json
}

resource "aws_lambda_permission" "this" {
  count = length(var.allowed_triggers)

  statement_id  = var.allowed_triggers[count.index].statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = var.allowed_triggers[count.index].principal
  source_arn    = var.allowed_triggers[count.index].source_arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(var.tags, { Name = "/aws/lambda/${local.function_name}" })
}

