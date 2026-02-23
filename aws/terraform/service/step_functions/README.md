# AWS Step Functions Terraform Module

This module creates an AWS Step Functions state machine with IAM roles, CloudWatch logging, and X-Ray tracing.

## Features

- State machine with Amazon States Language (ASL) definition
- Support for STANDARD and EXPRESS workflows
- Automatic IAM role creation with required permissions
- CloudWatch Logs integration with configurable retention
- X-Ray tracing support
- Custom IAM policies for service integrations

## Usage

### Basic Step Functions Workflow

```hcl
module "order_workflow" {
  source = "../../service/step_functions"

  project               = "myapp"
  environment           = "prod"
  state_machine_suffix  = "order-workflow"
  
  definition = jsonencode({
    Comment = "Order processing workflow"
    StartAt = "ProcessOrder"
    States = {
      ProcessOrder = {
        Type     = "Task"
        Resource = "arn:aws:lambda:us-east-1:123456789012:function:process-order"
        Next     = "SendNotification"
      }
      SendNotification = {
        Type     = "Task"
        Resource = "arn:aws:lambda:us-east-1:123456789012:function:send-notification"
        End      = true
      }
    }
  })
  
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          "arn:aws:lambda:us-east-1:123456789012:function:process-order",
          "arn:aws:lambda:us-east-1:123456789012:function:send-notification"
        ]
      }
    ]
  })
  
  tags = {
    Team = "platform"
  }
}
```

### Step Functions with Logging and Tracing

```hcl
module "data_pipeline" {
  source = "../../service/step_functions"

  project               = "myapp"
  environment           = "prod"
  state_machine_suffix  = "data-pipeline"
  
  definition = jsonencode({
    Comment = "Data processing pipeline"
    StartAt = "ExtractData"
    States = {
      ExtractData = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "extract-data"
        }
        Next = "TransformData"
      }
      TransformData = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "transform-data"
        }
        Next = "LoadData"
      }
      LoadData = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "load-data"
        }
        End = true
      }
    }
  })
  
  enable_xray_tracing = true
  
  logging_configuration = {
    log_group_arn          = module.log_group.log_group_arn
    include_execution_data = true
    level                  = "ALL"
  }
  
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:us-east-1:123456789012:function:*"
      }
    ]
  })
}
```

### Express Workflow (High-Volume, Low-Latency)

```hcl
module "event_processor" {
  source = "../../service/step_functions"

  project               = "myapp"
  environment           = "prod"
  state_machine_suffix  = "event-processor"
  state_machine_type    = "EXPRESS"
  
  definition = jsonencode({
    Comment = "High-volume event processing"
    StartAt = "ValidateEvent"
    States = {
      ValidateEvent = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "validate-event"
        }
        Next = "ProcessEvent"
      }
      ProcessEvent = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "process-event"
        }
        End = true
      }
    }
  })
  
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = "*"
      }
    ]
  })
}
```

### Workflow with DynamoDB and SNS Integration

```hcl
module "approval_workflow" {
  source = "../../service/step_functions"

  project               = "myapp"
  environment           = "prod"
  state_machine_suffix  = "approval-workflow"
  
  definition = jsonencode({
    Comment = "Approval workflow with DynamoDB and SNS"
    StartAt = "SaveRequest"
    States = {
      SaveRequest = {
        Type = "Task"
        Resource = "arn:aws:states:::dynamodb:putItem"
        Parameters = {
          TableName = "approvals"
          Item = {
            id = { "S.$" = "$.requestId" }
            status = { S = "pending" }
          }
        }
        Next = "SendNotification"
      }
      SendNotification = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = "arn:aws:sns:us-east-1:123456789012:approvals"
          Message = { "S.$" = "$.message" }
        }
        End = true
      }
    }
  })
  
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "dynamodb:PutItem"
        Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/approvals"
      },
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = "arn:aws:sns:us-east-1:123456789012:approvals"
      }
    ]
  })
}
```

### Parallel Processing Workflow

```hcl
module "parallel_processor" {
  source = "../../service/step_functions"

  project               = "myapp"
  environment           = "prod"
  state_machine_suffix  = "parallel-processor"
  
  definition = jsonencode({
    Comment = "Parallel processing workflow"
    StartAt = "ParallelProcessing"
    States = {
      ParallelProcessing = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "ProcessImageA"
            States = {
              ProcessImageA = {
                Type = "Task"
                Resource = "arn:aws:lambda:us-east-1:123456789012:function:process-image"
                End = true
              }
            }
          },
          {
            StartAt = "ProcessImageB"
            States = {
              ProcessImageB = {
                Type = "Task"
                Resource = "arn:aws:lambda:us-east-1:123456789012:function:process-image"
                End = true
              }
            }
          }
        ]
        Next = "AggregateResults"
      }
      AggregateResults = {
        Type = "Task"
        Resource = "arn:aws:lambda:us-east-1:123456789012:function:aggregate"
        End = true
      }
    }
  })
  
  custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = [
          "arn:aws:lambda:us-east-1:123456789012:function:process-image",
          "arn:aws:lambda:us-east-1:123456789012:function:aggregate"
        ]
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
| state_machine_suffix | Suffix for state machine name | `string` | n/a | yes |
| definition | ASL definition | `string` | n/a | yes |
| state_machine_type | Type (STANDARD or EXPRESS) | `string` | `"STANDARD"` | no |
| create_role | Create IAM role | `bool` | `true` | no |
| custom_policy_json | Custom IAM policy | `string` | `""` | no |
| enable_xray_tracing | Enable X-Ray tracing | `bool` | `false` | no |
| logging_configuration | Logging configuration | `object` | `null` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| state_machine_arn | ARN of the state machine |
| state_machine_name | Name of the state machine |
| role_arn | ARN of the IAM role |
| log_group_arn | ARN of the CloudWatch log group |

## State Machine Types

### STANDARD
- Maximum duration: 1 year
- Exactly-once workflow execution
- Pricing: Per state transition
- Use for: Long-running workflows, exactly-once semantics

### EXPRESS
- Maximum duration: 5 minutes
- At-least-once workflow execution
- Pricing: Number and duration of executions
- Use for: High-volume, event-processing workloads

## AWS Service Integrations

Step Functions can directly integrate with:
- Lambda functions
- DynamoDB (GetItem, PutItem, UpdateItem, etc.)
- SNS (Publish)
- SQS (SendMessage)
- ECS (RunTask)
- Batch (SubmitJob)
- Glue (StartJobRun)
- SageMaker (CreateTrainingJob)

## Logging Levels

- `ALL` - Log all events
- `ERROR` - Log only errors
- `FATAL` - Log only fatal errors
- `OFF` - No logging

## Notes

- State machine naming pattern: `{project}-{environment}-{state_machine_suffix}`
- Custom policies are required for service integrations
- X-Ray tracing helps debug distributed workflows
- Express workflows don't support all features (e.g., execution history)
- CloudWatch Logs are created in `/aws/vendedlogs/states/` namespace
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

