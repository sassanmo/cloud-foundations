module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.dynamodb_kms_policy

  tags = var.tags
}

module "dynamo_db" {
  source = "../../service/dynamo_db"

  account_id            = var.account_id
  region                = var.region
  partition             = var.partition
  table_name             = var.table_name
  billing_mode          = var.billing_mode
  hash_key              = var.hash_key
  range_key             = var.range_key
  read_capacity         = var.read_capacity
  write_capacity        = var.write_capacity
  attributes            = var.attributes
  global_secondary_indexes = var.global_secondary_indexes
  local_secondary_indexes = var.local_secondary_indexes
  enable_encryption     = true
  kms_key_arn          = module.kms.key_arn
  point_in_time_recovery = var.point_in_time_recovery
  ttl_attribute_name   = var.ttl_attribute_name
  stream_enabled       = var.stream_enabled
  stream_view_type     = var.stream_view_type

  tags = var.tags
}
