resource "aws_glue_catalog_database" "this" {
  name        = local.database_name
  description = var.description

  dynamic "target_database" {
    for_each = var.target_database != null ? [var.target_database] : []
    content {
      catalog_id    = target_database.value.catalog_id
      database_name = target_database.value.database_name
    }
  }

  tags = merge(var.tags, { Name = local.database_name })
}

resource "aws_glue_crawler" "this" {
  for_each = var.crawlers

  name          = "${local.database_name}-${each.key}"
  database_name = aws_glue_catalog_database.this.name
  role          = each.value.role_arn
  description   = each.value.description

  dynamic "s3_target" {
    for_each = each.value.s3_targets
    content {
      path                = s3_target.value.path
      connection_name     = s3_target.value.connection_name
      exclusions          = s3_target.value.exclusions
      sample_size         = s3_target.value.sample_size
      event_queue_arn     = s3_target.value.event_queue_arn
      dlq_event_queue_arn = s3_target.value.dlq_event_queue_arn
    }
  }

  dynamic "jdbc_target" {
    for_each = each.value.jdbc_targets != null ? each.value.jdbc_targets : []
    content {
      connection_name = jdbc_target.value.connection_name
      path            = jdbc_target.value.path
      exclusions      = jdbc_target.value.exclusions
    }
  }

  dynamic "schema_change_policy" {
    for_each = each.value.schema_change_policy != null ? [each.value.schema_change_policy] : []
    content {
      delete_behavior = schema_change_policy.value.delete_behavior
      update_behavior = schema_change_policy.value.update_behavior
    }
  }

  schedule = each.value.schedule

  tags = merge(var.tags, { Name = "${local.database_name}-${each.key}" })
}

resource "aws_glue_job" "this" {
  for_each = var.jobs

  name         = "${local.database_name}-${each.key}"
  description  = each.value.description
  role_arn     = each.value.role_arn
  glue_version = each.value.glue_version

  command {
    name            = each.value.command_name
    script_location = each.value.script_location
    python_version  = each.value.python_version
  }

  default_arguments = each.value.default_arguments

  max_retries       = each.value.max_retries
  timeout           = each.value.timeout
  max_capacity      = each.value.max_capacity
  number_of_workers = each.value.number_of_workers
  worker_type       = each.value.worker_type

  dynamic "execution_property" {
    for_each = each.value.max_concurrent_runs != null ? [1] : []
    content {
      max_concurrent_runs = each.value.max_concurrent_runs
    }
  }

  tags = merge(var.tags, { Name = "${local.database_name}-${each.key}" })
}

resource "aws_glue_trigger" "this" {
  for_each = var.triggers

  name        = "${local.database_name}-${each.key}"
  description = each.value.description
  type        = each.value.type
  enabled     = each.value.enabled
  schedule    = each.value.schedule

  actions {
    job_name = aws_glue_job.this[each.value.job_key].name
    arguments = each.value.arguments
    timeout   = each.value.timeout
  }

  dynamic "predicate" {
    for_each = each.value.predicate != null ? [each.value.predicate] : []
    content {
      logical = predicate.value.logical

      dynamic "conditions" {
        for_each = predicate.value.conditions
        content {
          job_name         = conditions.value.job_name
          state            = conditions.value.state
          logical_operator = conditions.value.logical_operator
          crawl_state      = conditions.value.crawl_state
          crawler_name     = conditions.value.crawler_name
        }
      }
    }
  }

  tags = merge(var.tags, { Name = "${local.database_name}-${each.key}" })
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
