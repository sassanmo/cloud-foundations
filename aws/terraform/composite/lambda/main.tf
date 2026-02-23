module "secrets_manager" {
  count = length(var.secrets) > 0 ? 1 : 0
  source = "../secrets_manager"

  account_id = var.account_id
  region     = var.region
  partition  = var.partition

  environment        = var.environment
  project            = var.project
  secrets = {
    default = {
      description      = "Secrets for ${var.function_name} Lambda function"
      secret_string    = jsonencode(var.secrets)
      secret_key_value = {}
      recovery_window_in_days = 7
      rotation         = {}
      policy           = ""
      tags             = {}
    }
  }

  tags = var.tags
}

module "iam_role" {
  source = "../../service/iam_role"

  account_id         = var.account_id
  region             = var.region
  partition          = var.partition
  environment        = var.environment
  project            = var.project
  role_suffix        = var.function_name
  assume_role_policy = local.lambda_assume_role_policy
  managed_policy_arns = local.lambda_policy_arns

  tags = var.tags
}

# Separate IAM policy for Secrets Manager access (created after secrets are available)
resource "aws_iam_role_policy" "secrets_manager_access" {
  count = length(var.secrets) > 0 ? 1 : 0

  name = "${var.function_name}-secrets-policy"
  role = module.iam_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.secrets_manager[0].secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = module.secrets_manager[0].kms_key_arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

module "cloudwatch_logs" {
  source = "../../service/cloudwatch_logs"

  account_id            = var.account_id
  region                = var.region
  partition             = var.partition
  environment           = var.environment
  project               = var.project
  log_group_name        = local.log_group_name
  retention_in_days     = var.log_retention_days
  kms_key_id           = var.log_group_kms_key_id

  tags = var.tags
}

module "lambda" {
  source = "../../service/lambda"

  account_id       = var.account_id
  region           = var.region
  partition        = var.partition
  region           = var.region
  environment      = var.environment
  project          = var.project
  function_name_suffix = var.function_name
  create_role     = false
  existing_role_arn = module.iam_role.arn

  filename         = var.filename
  source_code_hash = var.source_code_hash
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version

  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  architectures    = var.architectures

  publish          = var.publish
  layers           = var.layers

  environment_variables = merge(
    var.environment_variables,
    length(var.secrets) > 0 ? {
      SECRETS_MANAGER_SECRET_ARN = module.secrets_manager[0].secret_arn
    } : {}
  )
  vpc_subnet_ids       = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  reserved_concurrent_executions = var.reserved_concurrent_executions
  dead_letter_config            = var.dead_letter_config

  depends_on = [module.cloudwatch_logs]

  tags = var.tags
}
