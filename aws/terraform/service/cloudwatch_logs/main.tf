resource "aws_cloudwatch_log_group" "this" {
  name              = "${local.log_group_prefix}${var.log_group_name}"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id

  tags = merge(var.tags, var.log_group_tags, { Name = "${local.log_group_prefix}${var.log_group_name}" })
}

resource "aws_cloudwatch_log_stream" "this" {
  for_each = var.log_streams

  name           = each.value.stream_name
  log_group_name = aws_cloudwatch_log_group.this.name
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.metric_filters

  name           = each.key
  log_group_name = aws_cloudwatch_log_group.this.name
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
  log_group_name  = aws_cloudwatch_log_group.this.name
  filter_pattern  = each.value.filter_pattern
  destination_arn = each.value.destination_arn
  role_arn        = each.value.role_arn
}

resource "aws_cloudwatch_query_definition" "this" {
  for_each = var.query_definitions

  name            = each.key
  log_group_names = [aws_cloudwatch_log_group.this.name]
  query_string    = each.value.query_string
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
