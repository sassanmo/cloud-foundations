# AWS CloudWatch Logs Terraform Module

This module creates and manages AWS CloudWatch Log Groups, Streams, Metric Filters, and Subscription Filters.

## Features

- CloudWatch log groups with configurable retention
- Log streams for organized logging
- Metric filters to create metrics from log events
- Subscription filters for streaming logs to other services
- CloudWatch Insights query definitions
- KMS encryption support

## Usage

```hcl
module "logs" {
  source = "../../service/cloudwatch_logs"

  project     = "myapp"
  environment = "prod"
  
  log_groups = {
    application = {
      retention_in_days = 30
    }
    
    audit = {
      retention_in_days = 365
      kms_key_id        = aws_kms_key.logs.id
    }
  }
  
  metric_filters = {
    error_count = {
      log_group_key    = "application"
      pattern          = "[time, request_id, level = ERROR*, ...]"
      metric_name      = "ErrorCount"
      metric_namespace = "MyApp"
      metric_value     = "1"
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

## Examples

### Log Groups with Streams

```hcl
module "logs" {
  source = "../../service/cloudwatch_logs"

  project     = "myapp"
  environment = "prod"
  
  log_groups = {
    app = {
      retention_in_days = 14
    }
  }
  
  log_streams = {
    instance_1 = {
      log_group_key = "app"
      stream_name   = "i-1234567890abcdef0"
    }
    instance_2 = {
      log_group_key = "app"
      stream_name   = "i-0987654321fedcba0"
    }
  }
}
```

### Subscription Filter to Kinesis

```hcl
module "logs" {
  source = "../../service/cloudwatch_logs"

  project     = "myapp"
  environment = "prod"
  
  log_groups = {
    application = {
      retention_in_days = 30
    }
  }
  
  subscription_filters = {
    to_kinesis = {
      log_group_key   = "application"
      filter_pattern  = ""
      destination_arn = aws_kinesis_stream.logs.arn
      role_arn        = aws_iam_role.cloudwatch_to_kinesis.arn
    }
  }
}
```

### Query Definitions

```hcl
module "logs" {
  source = "../../service/cloudwatch_logs"

  project     = "myapp"
  environment = "prod"
  
  log_groups = {
    app = {
      retention_in_days = 30
    }
  }
  
  query_definitions = {
    error_analysis = {
      log_group_keys = ["app"]
      query_string   = <<-QUERY
        fields @timestamp, @message
        | filter @message like /ERROR/
        | stats count() by bin(5m)
      QUERY
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
| log_groups | Map of log groups | `map(object)` | `{}` | no |
| log_streams | Map of log streams | `map(object)` | `{}` | no |
| metric_filters | Map of metric filters | `map(object)` | `{}` | no |
| subscription_filters | Map of subscription filters | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_group_names | Map of log group names |
| log_group_arns | Map of log group ARNs |
| log_stream_names | Map of log stream names |
| metric_filter_names | Map of metric filter names |
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = "${local.log_group_prefix}${each.key}"
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id

  tags = merge(var.tags, each.value.tags, { Name = "${local.log_group_prefix}${each.key}" })
}

resource "aws_cloudwatch_log_stream" "this" {
  for_each = var.log_streams

  name           = each.value.stream_name
  log_group_name = aws_cloudwatch_log_group.this[each.value.log_group_key].name
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.metric_filters

  name           = each.key
  log_group_name = aws_cloudwatch_log_group.this[each.value.log_group_key].name
  pattern        = each.value.pattern

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = each.value.metric_default_value
    unit          = each.value.metric_unit
  }
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = var.subscription_filters

  name            = each.key
  log_group_name  = aws_cloudwatch_log_group.this[each.value.log_group_key].name
  filter_pattern  = each.value.filter_pattern
  destination_arn = each.value.destination_arn
  role_arn        = each.value.role_arn
}

resource "aws_cloudwatch_query_definition" "this" {
  for_each = var.query_definitions

  name = each.key

  log_group_names = [
    for log_group_key in each.value.log_group_keys :
    aws_cloudwatch_log_group.this[log_group_key].name
  ]

  query_string = each.value.query_string
}

