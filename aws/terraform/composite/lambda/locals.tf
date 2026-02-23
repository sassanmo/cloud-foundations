locals {
  lambda_role_name = "${var.function_name}-role"
  log_group_name   = "/aws/lambda/${var.function_name}"

  lambda_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Base policies for Lambda execution
  base_lambda_policies = [
    "arn:${var.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  # VPC policies if Lambda is in VPC
  vpc_policies = var.vpc_subnet_ids != null ? [
    "arn:${var.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ] : []

  # Combine all managed policy ARNs (no Secrets Manager managed policy needed)
  lambda_policy_arns = concat(
    local.base_lambda_policies,
    local.vpc_policies,
    var.additional_policy_arns
  )
}

