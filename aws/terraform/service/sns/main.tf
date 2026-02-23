resource "aws_sns_topic" "this" {
  name              = local.topic_name
  fifo_topic        = var.fifo_topic
  kms_master_key_id = local.kms_master_key_id

  tags = var.tags
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy != "" ? var.topic_policy : data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "AllowAccountPublish"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${var.partition}:iam::${var.account_id}:root"]
    }
    actions   = ["SNS:Publish", "SNS:Subscribe", "SNS:Receive", "SNS:GetTopicAttributes", "SNS:SetTopicAttributes"]
    resources = [aws_sns_topic.this.arn]
  }
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for s in var.subscriptions : "${s.protocol}-${s.endpoint}" => s }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
