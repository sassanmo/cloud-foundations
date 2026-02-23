resource "aws_athena_workgroup" "this" {
  name        = local.workgroup_name
  description = var.description
  state       = var.state

  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query

    result_configuration {
      output_location = var.output_location

      dynamic "encryption_configuration" {
        for_each = var.encryption_configuration != null ? [var.encryption_configuration] : []
        content {
          encryption_option = encryption_configuration.value.encryption_option
          kms_key_arn       = encryption_configuration.value.kms_key_arn
        }
      }
    }

    engine_version {
      selected_engine_version = var.engine_version
    }
  }

  tags = merge(var.tags, { Name = local.workgroup_name })
}

resource "aws_athena_database" "this" {
  for_each = var.databases

  name          = each.key
  bucket        = each.value.bucket
  comment       = each.value.comment
  force_destroy = each.value.force_destroy

  dynamic "encryption_configuration" {
    for_each = each.value.encryption_configuration != null ? [each.value.encryption_configuration] : []
    content {
      encryption_option = encryption_configuration.value.encryption_option
      kms_key           = encryption_configuration.value.kms_key
    }
  }
}

resource "aws_athena_named_query" "this" {
  for_each = var.named_queries

  name        = each.key
  workgroup   = aws_athena_workgroup.this.id
  database    = each.value.database
  query       = each.value.query
  description = each.value.description
}

