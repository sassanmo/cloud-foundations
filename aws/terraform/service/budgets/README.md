# AWS Budgets Service Module

This module provides a reusable Terraform configuration for deploying AWS Budgets to monitor and control costs.

## Features

- **Cost Monitoring**: Track AWS spending and usage
- **Budget Alerts**: Email and SNS notifications when thresholds are exceeded
- **Flexible Periods**: Daily, monthly, quarterly, or annual budgets
- **Cost Filters**: Filter by service, tag, or other dimensions
- **Auto-Adjustment**: Automatically adjust budgets based on historical data
- **Multiple Notification Types**: Actual costs, forecasted costs, or percentage thresholds

## Usage

### Basic Monthly Budget

```hcl
module "monthly_budget" {
  source = "./service/budgets"

  environment  = "prod"
  project      = "myapp"
  budget_name  = "monthly-cost"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["team@example.com"]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 100
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["alerts@example.com"]
    }
  ]
}
```

### Budget with SNS Notifications

```hcl
module "budget_with_sns" {
  source = "./service/budgets"

  environment  = "prod"
  project      = "myapp"
  budget_name  = "monthly-cost"
  budget_type  = "COST"
  limit_amount = "5000"
  time_unit    = "MONTHLY"

  notifications = [
    {
      comparison_operator       = "GREATER_THAN"
      threshold                 = 90
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_sns_topic_arns = ["arn:aws:sns:us-east-1:123456789012:budget-alerts"]
    }
  ]
}
```

### Budget with Cost Filters

```hcl
module "ec2_budget" {
  source = "./service/budgets"

  environment  = "prod"
  project      = "myapp"
  budget_name  = "ec2-monthly"
  budget_type  = "COST"
  limit_amount = "2000"
  time_unit    = "MONTHLY"

  cost_filters = {
    Service = ["Amazon Elastic Compute Cloud - Compute"]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["devops@example.com"]
    }
  ]
}
```

### Budget with Auto-Adjustment

```hcl
module "auto_adjust_budget" {
  source = "./service/budgets"

  environment  = "prod"
  project      = "myapp"
  budget_name  = "auto-adjusted"
  budget_type  = "COST"
  limit_amount = "1000"
  time_unit    = "MONTHLY"

  auto_adjust_data = {
    auto_adjust_type           = "HISTORICAL"
    lookback_available_periods = 6
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 100
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["finance@example.com"]
    }
  ]
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
| budget_name | Budget name suffix | `string` | n/a | yes |
| limit_amount | Budget limit amount | `string` | n/a | yes |
| budget_type | Budget type | `string` | `"COST"` | no |
| time_unit | Time unit | `string` | `"MONTHLY"` | no |
| notifications | Notification configuration | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| budget_name | Name of the budget |
| budget_arn | ARN of the budget |
| budget_id | ID of the budget |

## Notes

- Budgets are created at the account level
- Email subscribers must confirm their subscription
- SNS topics must have appropriate permissions for AWS Budgets
- Cost filters are additive (AND logic)
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

