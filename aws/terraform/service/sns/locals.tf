locals {
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.name
  kms_master_key_id = var.kms_master_key_id != "" ? var.kms_master_key_id : null
  topic_name        = var.fifo_topic && !endswith(var.name, ".fifo") ? "${var.name}.fifo" : var.name
}
