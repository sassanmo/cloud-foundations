module "sns" {
  source = "../../service/sns"

  account_id        = var.account_id
  region            = var.region
  partition         = var.partition
  name              = var.name
  fifo_topic        = var.fifo
  kms_master_key_id = var.kms_master_key_id

  tags = var.tags
}

module "sqs" {
  source = "../../service/sqs"

  account_id                 = var.account_id
  region                     = var.region
  partition                  = var.partition
  name                       = var.name
  fifo_queue                 = var.fifo
  kms_master_key_id          = var.kms_master_key_id
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  create_dlq                 = true
  dlq_max_receive_count      = var.dlq_max_receive_count

  tags = var.tags
}

resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = module.sns.topic_arn
  protocol  = "sqs"
  endpoint  = module.sqs.queue_arn

  raw_message_delivery = !var.fifo
}

resource "aws_sqs_queue_policy" "sns_subscription" {
  queue_url = module.sqs.queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = module.sqs.queue_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.sns.topic_arn
          }
        }
      }
    ]
  })
}
