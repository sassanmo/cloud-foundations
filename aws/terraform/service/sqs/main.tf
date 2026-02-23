resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                              = local.dlq_name
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.fifo_queue ? var.content_based_deduplication : null
  kms_master_key_id                 = local.kms_master_key_id
  message_retention_seconds         = 1209600  # 14 days for DLQ

  tags = merge(var.tags, { Name = local.dlq_name })
}

resource "aws_sqs_queue" "this" {
  name                              = local.queue_name
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.fifo_queue ? var.content_based_deduplication : null
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  kms_master_key_id                 = local.kms_master_key_id

  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.dlq_max_receive_count
  }) : null

  tags = merge(var.tags, { Name = local.queue_name })
}

resource "aws_sqs_queue_policy" "this" {
  count     = var.queue_policy != "" ? 1 : 0
  queue_url = aws_sqs_queue.this.id
  policy    = var.queue_policy
}
