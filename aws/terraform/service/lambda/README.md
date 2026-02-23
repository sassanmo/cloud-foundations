# AWS Lambda Terraform Module

This module creates an AWS Lambda function with associated IAM roles and CloudWatch log groups.

## Features

- Lambda function with customizable runtime and configuration
- Optional IAM role creation with basic execution policies
- VPC configuration support
- Dead letter queue configuration
- Environment variables with KMS encryption
- CloudWatch log group with configurable retention
- Lambda permissions for external triggers

## Usage

```hcl
module "lambda" {
  source = "../../service/lambda"

  project               = "myapp"
  environment           = "prod"
  function_name_suffix  = "processor"
  
  handler  = "index.handler"
  runtime  = "nodejs18.x"
  filename = "lambda.zip"
  
  timeout     = 30
  memory_size = 256
  
  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "info"
  }
  
  tags = {
    Team = "platform"
  }
}
```

## Examples

### Lambda with S3 Deployment Package

```hcl
module "lambda" {
  source = "../../service/lambda"

  project              = "myapp"
  environment          = "prod"
  function_name_suffix = "api"
  
  handler = "app.lambda_handler"
  runtime = "python3.11"
  
  s3_bucket = "my-lambda-deployments"
  s3_key    = "lambda-api-v1.0.0.zip"
  
  timeout     = 60
  memory_size = 512
}
```

### Lambda in VPC with Custom IAM Policy

```hcl
module "lambda" {
  source = "../../service/lambda"

  project              = "myapp"
  environment          = "prod"
  function_name_suffix = "worker"
  
  handler  = "main"
  runtime  = "go1.x"
  filename = "bootstrap.zip"
  
  vpc_subnet_ids         = ["subnet-12345", "subnet-67890"]
  vpc_security_group_ids = ["sg-12345"]
  
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/my-table"
      }
    ]
  })
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| function_name_suffix | Suffix for the Lambda function name | `string` | n/a | yes |
| handler | Lambda function handler | `string` | n/a | yes |
| runtime | Lambda runtime | `string` | n/a | yes |
| timeout | Function timeout in seconds | `number` | `3` | no |
| memory_size | Amount of memory in MB | `number` | `128` | no |
| architectures | Instruction set architecture | `list(string)` | `["x86_64"]` | no |
| environment_variables | Map of environment variables | `map(string)` | `{}` | no |
| vpc_subnet_ids | List of subnet IDs for VPC | `list(string)` | `null` | no |
| create_role | Whether to create IAM role | `bool` | `true` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | Name of the Lambda function |
| function_arn | ARN of the Lambda function |
| function_invoke_arn | Invoke ARN of the Lambda function |
| role_arn | ARN of the IAM role |
| log_group_name | Name of the CloudWatch log group |
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count = var.create_role && var.vpc_subnet_ids != null ? 1 : 0
  
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
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

