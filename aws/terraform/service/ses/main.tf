resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_ses_domain_mail_from" "this" {
  count = var.mail_from_domain != null ? 1 : 0

  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = var.mail_from_domain
}

resource "aws_ses_email_identity" "this" {
  for_each = toset(var.email_identities)

  email = each.value
}

resource "aws_ses_configuration_set" "this" {
  name = local.configuration_set_name

  reputation_metrics_enabled = var.reputation_metrics_enabled
}

resource "aws_ses_event_destination" "this" {
  for_each = var.event_destinations

  name                   = each.key
  configuration_set_name = aws_ses_configuration_set.this.name
  enabled                = each.value.enabled
  matching_types         = each.value.matching_types

  dynamic "cloudwatch_destination" {
    for_each = each.value.cloudwatch_destination != null ? [each.value.cloudwatch_destination] : []
    content {
      default_value  = cloudwatch_destination.value.default_value
      dimension_name = cloudwatch_destination.value.dimension_name
      value_source   = cloudwatch_destination.value.value_source
    }
  }

  dynamic "sns_destination" {
    for_each = each.value.sns_topic_arn != null ? [1] : []
    content {
      topic_arn = each.value.sns_topic_arn
    }
  }
}

