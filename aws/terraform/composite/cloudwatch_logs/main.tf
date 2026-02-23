module "kms" {
  source = "../../service/kms"

  account_id          = var.account_id
  region              = var.region
  partition           = var.partition
  alias_name          = local.kms_alias_name
  description         = var.kms_description
  enable_key_rotation = true
  policy              = local.cloudwatch_logs_kms_policy

  tags = var.tags
}

module "cloudwatch_logs" {
  source = "../../service/cloudwatch_logs"

  account_id         = var.account_id
  region             = var.region
  partition          = var.partition
  environment        = var.environment
  project            = var.project
  log_group_name     = var.log_group_name
  retention_in_days  = var.retention_in_days
  kms_key_id         = module.kms.key_id
  log_group_tags     = var.log_group_tags
  log_streams        = var.log_streams
  metric_filters     = var.metric_filters
  subscription_filters = var.subscription_filters
  query_definitions  = var.query_definitions

  tags = var.tags
}
