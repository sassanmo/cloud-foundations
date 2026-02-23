locals {
  kms_master_key_id = var.kms_master_key_id != "" ? var.kms_master_key_id : null
  queue_name        = var.fifo_queue && !endswith(var.name, ".fifo") ? "${var.name}.fifo" : var.name
  dlq_name          = var.fifo_queue && !endswith(var.name, ".fifo") ? "${var.name}-dlq.fifo" : "${var.name}-dlq"
}
