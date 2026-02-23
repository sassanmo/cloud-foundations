resource "aws_budgets_budget" "this" {
  name              = local.budget_name
  budget_type       = var.budget_type
  limit_amount      = var.limit_amount
  limit_unit        = var.limit_unit
  time_unit         = var.time_unit
  time_period_start = var.time_period_start
  time_period_end   = var.time_period_end

  cost_filter {
    name   = "TagKeyValue"
    values = ["user:Project$${var.project}"]
  }

  dynamic "cost_filter" {
    for_each = var.cost_filters
    content {
      name   = cost_filter.key
      values = cost_filter.value
    }
  }

  cost_types {
    include_credit             = try(var.cost_types.include_credit, false)
    include_discount           = try(var.cost_types.include_discount, true)
    include_other_subscription = try(var.cost_types.include_other_subscription, true)
    include_recurring          = try(var.cost_types.include_recurring, true)
    include_refund             = try(var.cost_types.include_refund, false)
    include_subscription       = try(var.cost_types.include_subscription, true)
    include_support            = try(var.cost_types.include_support, true)
    include_tax                = try(var.cost_types.include_tax, true)
    include_upfront            = try(var.cost_types.include_upfront, true)
    use_blended                = try(var.cost_types.use_blended, false)
  }

  dynamic "notification" {
    for_each = var.notifications
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns
    }
  }

  dynamic "auto_adjust_data" {
    for_each = var.auto_adjust_data != null ? [var.auto_adjust_data] : []
    content {
      auto_adjust_type = auto_adjust_data.value.auto_adjust_type

      dynamic "historical_options" {
        for_each = auto_adjust_data.value.auto_adjust_type == "HISTORICAL" ? [1] : []
        content {
          budget_adjustment_period = auto_adjust_data.value.lookback_available_periods
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = local.budget_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

