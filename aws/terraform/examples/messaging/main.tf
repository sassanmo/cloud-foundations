# Example: SNS topic and SQS queue with fan-out pattern
module "order_events" {
  source = "../../composite/sqs_with_sns"

  name              = "order-events"
  kms_master_key_id = "alias/aws/sqs"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400  # 1 day
  dlq_max_receive_count      = 5

  tags = {
    Environment = "example"
    Module      = "sqs_with_sns"
  }
}

# Example: Standalone SQS queue
module "processing_queue" {
  source = "../../service/sqs"

  name              = "order-processing"
  kms_master_key_id = "alias/aws/sqs"
  create_dlq        = true

  tags = {
    Environment = "example"
    Module      = "sqs"
  }
}
