# AWS EventBridge Terraform Module

This module creates AWS EventBridge resources including event buses, rules, targets, and archives.

## Features

- Custom event bus creation
- EventBridge rules with event patterns or schedules
- Multiple target types (Lambda, ECS, SNS, SQS, etc.)
- Input transformers for targets
- Retry policies and dead letter queues
- Event archives with configurable retention

## Usage

```hcl
module "eventbridge" {
  source = "../../service/eventbridge"

  project     = "myapp"
  environment = "prod"
  
  rules = {
    order_created = {
      description   = "Trigger on order creation"
      event_pattern = jsonencode({
        source      = ["myapp.orders"]
        detail-type = ["Order Created"]
      })
    }
    
    daily_report = {
      description         = "Daily report generation"
      schedule_expression = "cron(0 8 * * ? *)"
    }
  }
  
  targets = {
    order_processor = {
      rule_key = "order_created"
      arn      = module.lambda.function_arn
    }
    
    report_generator = {
      rule_key = "daily_report"
      arn      = module.lambda_report.function_arn
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

## Examples

### EventBridge with ECS Target

```hcl
module "eventbridge" {
  source = "../../service/eventbridge"

  project     = "myapp"
  environment = "prod"
  
  rules = {
    batch_processing = {
      description         = "Run batch job every hour"
      schedule_expression = "rate(1 hour)"
    }
  }
  
  targets = {
    ecs_batch = {
      rule_key = "batch_processing"
      arn      = aws_ecs_cluster.main.arn
      role_arn = aws_iam_role.eventbridge.arn
      
      ecs_target = {
        task_definition_arn = aws_ecs_task_definition.batch.arn
        task_count          = 1
        launch_type         = "FARGATE"
        
        network_configuration = {
          subnets          = ["subnet-12345"]
          security_groups  = ["sg-12345"]
          assign_public_ip = true
        }
      }
    }
  }
}
```

### EventBridge with Archives

```hcl
module "eventbridge" {
  source = "../../service/eventbridge"

  project     = "myapp"
  environment = "prod"
  
  archives = {
    all_events = {
      description    = "Archive all events"
      retention_days = 90
    }
    
    errors_only = {
      description    = "Archive error events"
      retention_days = 365
      event_pattern  = jsonencode({
        detail = {
          status = ["ERROR", "FAILED"]
        }
      })
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| create_event_bus | Whether to create event bus | `bool` | `true` | no |
| rules | Map of EventBridge rules | `map(object)` | `{}` | no |
| targets | Map of EventBridge targets | `map(object)` | `{}` | no |
| archives | Map of EventBridge archives | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| event_bus_name | Name of the EventBridge event bus |
| event_bus_arn | ARN of the EventBridge event bus |
| rule_arns | Map of EventBridge rule ARNs |
| archive_arns | Map of EventBridge archive ARNs |
resource "aws_cloudwatch_event_bus" "this" {
  count = var.create_event_bus ? 1 : 0
  
  name = local.event_bus_name
  
  tags = merge(var.tags, { Name = local.event_bus_name })
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.rules
  
  name           = "${local.event_bus_name}-${each.key}"
  description    = each.value.description
  event_bus_name = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].name : var.event_bus_name
  event_pattern  = each.value.event_pattern
  schedule_expression = each.value.schedule_expression
  is_enabled     = each.value.is_enabled
  
  tags = merge(var.tags, { Name = "${local.event_bus_name}-${each.key}" })
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = var.targets
  
  rule           = aws_cloudwatch_event_rule.this[each.value.rule_key].name
  event_bus_name = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].name : var.event_bus_name
  target_id      = each.key
  arn            = each.value.arn
  
  role_arn = each.value.role_arn
  
  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }
  
  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      maximum_event_age       = retry_policy.value.maximum_event_age
      maximum_retry_attempts  = retry_policy.value.maximum_retry_attempts
    }
  }
  
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_arn != null ? [1] : []
    content {
      arn = each.value.dead_letter_arn
    }
  }
  
  dynamic "ecs_target" {
    for_each = each.value.ecs_target != null ? [each.value.ecs_target] : []
    content {
      task_definition_arn = ecs_target.value.task_definition_arn
      task_count          = ecs_target.value.task_count
      launch_type         = ecs_target.value.launch_type
      platform_version    = ecs_target.value.platform_version
      
      dynamic "network_configuration" {
        for_each = ecs_target.value.network_configuration != null ? [ecs_target.value.network_configuration] : []
        content {
          subnets          = network_configuration.value.subnets
          security_groups  = network_configuration.value.security_groups
          assign_public_ip = network_configuration.value.assign_public_ip
        }
      }
    }
  }
  
  input = each.value.input
}

resource "aws_cloudwatch_event_archive" "this" {
  for_each = var.archives
  
  name             = "${local.event_bus_name}-${each.key}"
  description      = each.value.description
  event_source_arn = var.create_event_bus ? aws_cloudwatch_event_bus.this[0].arn : data.aws_cloudwatch_event_bus.existing[0].arn
  retention_days   = each.value.retention_days
  event_pattern    = each.value.event_pattern
}

data "aws_cloudwatch_event_bus" "existing" {
  count = var.create_event_bus ? 0 : 1
  name  = var.event_bus_name
}

