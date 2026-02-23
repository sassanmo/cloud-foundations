# AWS CloudWatch Alarms Terraform Module

This module creates a CloudWatch metric alarm for monitoring AWS resources and triggering notifications.

## Features

- Metric-based alarms with flexible comparison operators
- Configurable evaluation periods and datapoints
- SNS integration for notifications
- Multiple action types (alarm, ok, insufficient data)
- Support for custom dimensions
- Treat missing data configuration

## Usage

### Lambda Error Rate Alarm

```hcl
module "lambda_error_alarm" {
  source = "../../service/cloudwatch_alarms"

  project      = "myapp"
  environment  = "prod"
  alarm_suffix = "lambda-errors"
  
  alarm_description   = "Lambda function error rate is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  
  dimensions = {
    FunctionName = "myapp-prod-processor"
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = {
    Team = "platform"
  }
}
```

### ALB Target Health Alarm

```hcl
module "alb_unhealthy_target_alarm" {
  source = "../../service/cloudwatch_alarms"

  project      = "myapp"
  environment  = "prod"
  alarm_suffix = "alb-unhealthy-targets"
  
  alarm_description   = "ALB has unhealthy targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  
  dimensions = {
    LoadBalancer = "app/myapp-prod-alb/1234567890"
    TargetGroup  = "targetgroup/myapp-prod-web/9876543210"
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
```

### RDS CPU Utilization Alarm

```hcl
module "rds_cpu_alarm" {
  source = "../../service/cloudwatch_alarms"

  project      = "myapp"
  environment  = "prod"
  alarm_suffix = "rds-cpu-high"
  
  alarm_description   = "RDS CPU utilization is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = "myapp-prod-db"
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

### SQS Queue Depth Alarm

```hcl
module "sqs_queue_depth_alarm" {
  source = "../../service/cloudwatch_alarms"

  project      = "myapp"
  environment  = "prod"
  alarm_suffix = "sqs-queue-depth"
  
  alarm_description   = "SQS queue has too many messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000
  
  dimensions = {
    QueueName = "myapp-prod-queue"
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

### DynamoDB Throttled Requests Alarm

```hcl
module "dynamodb_throttle_alarm" {
  source = "../../service/cloudwatch_alarms"

  project      = "myapp"
  environment  = "prod"
  alarm_suffix = "dynamodb-throttles"
  
  alarm_description   = "DynamoDB table is being throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  
  dimensions = {
    TableName = "myapp-prod-table"
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

### API Gateway 5XX Error Alarm

```hcl
module "api_gateway_5xx_alarm" {
  source = "../../service/cloudwatch_alarms"

  project      = "myapp"
  environment  = "prod"
  alarm_suffix = "api-5xx-errors"
  
  alarm_description   = "API Gateway 5XX error rate is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  
  dimensions = {
    ApiName = "myapp-prod-api"
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

### Multiple Alarms for a Resource

```hcl
# CPU alarm
module "cpu_alarm" {
  source = "../../service/cloudwatch_alarms"

  project             = "myapp"
  environment         = "prod"
  alarm_suffix        = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = 80
  
  dimensions = { InstanceId = aws_instance.app.id }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Memory alarm
module "memory_alarm" {
  source = "../../service/cloudwatch_alarms"

  project             = "myapp"
  environment         = "prod"
  alarm_suffix        = "memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  threshold           = 85
  
  dimensions = { InstanceId = aws_instance.app.id }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Disk alarm
module "disk_alarm" {
  source = "../../service/cloudwatch_alarms"

  project             = "myapp"
  environment         = "prod"
  alarm_suffix        = "disk-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  threshold           = 90
  
  dimensions = { 
    InstanceId = aws_instance.app.id
    path       = "/"
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
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
| alarm_suffix | Suffix for alarm name | `string` | n/a | yes |
| comparison_operator | Comparison operator | `string` | n/a | yes |
| evaluation_periods | Number of evaluation periods | `number` | n/a | yes |
| metric_name | Name of the metric | `string` | n/a | yes |
| namespace | Metric namespace | `string` | n/a | yes |
| threshold | Alarm threshold | `number` | n/a | yes |
| period | Period in seconds | `number` | `300` | no |
| statistic | Statistic type | `string` | `"Average"` | no |
| datapoints_to_alarm | Datapoints to alarm | `number` | `null` | no |
| dimensions | Metric dimensions | `map(string)` | `{}` | no |
| alarm_actions | Alarm action ARNs | `list(string)` | `[]` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alarm_arn | ARN of the CloudWatch alarm |
| alarm_name | Name of the CloudWatch alarm |
| alarm_id | ID of the CloudWatch alarm |

## Comparison Operators

- `GreaterThanOrEqualToThreshold`
- `GreaterThanThreshold`
- `LessThanThreshold`
- `LessThanOrEqualToThreshold`

## Statistics

- `SampleCount` - Number of data points
- `Average` - Average of data points
- `Sum` - Sum of data points
- `Minimum` - Minimum value
- `Maximum` - Maximum value

## Treat Missing Data

- `missing` - Alarm evaluates as missing (default)
- `notBreaching` - Missing data treated as good
- `breaching` - Missing data treated as bad
- `ignore` - Ignore missing data

## Common AWS Namespaces

- `AWS/Lambda` - Lambda functions
- `AWS/RDS` - RDS databases
- `AWS/EC2` - EC2 instances
- `AWS/ApplicationELB` - Application Load Balancers
- `AWS/SQS` - SQS queues
- `AWS/SNS` - SNS topics
- `AWS/DynamoDB` - DynamoDB tables
- `AWS/ApiGateway` - API Gateway
- `AWS/ECS` - ECS services
- `CWAgent` - CloudWatch Agent (custom metrics)

## Notes

- Alarm naming pattern: `{project}-{environment}-{alarm_suffix}`
- Use `datapoints_to_alarm` to require multiple breaches before alarming
- Combine with SNS topics for email, SMS, or webhook notifications
- To create multiple alarms, call this module multiple times with different `alarm_suffix` values
resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = local.alarm_name
  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  treat_missing_data  = var.treat_missing_data
  
  datapoints_to_alarm = var.datapoints_to_alarm
  
  dimensions = var.dimensions
  
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  
  tags = merge(var.tags, { Name = local.alarm_name })
}

