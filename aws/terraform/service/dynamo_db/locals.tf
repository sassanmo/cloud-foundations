locals {
  has_range_key = var.range_key != ""

  attribute_definitions = concat(
    [{ name = var.hash_key, type = var.hash_key_type }],
    local.has_range_key ? [{ name = var.range_key, type = var.range_key_type }] : [],
    [for gsi in var.global_secondary_indexes : { name = gsi.hash_key, type = gsi.hash_key_type } if gsi.hash_key != var.hash_key && (local.has_range_key ? gsi.hash_key != var.range_key : true)],
    flatten([for gsi in var.global_secondary_indexes : gsi.range_key != null ? [{ name = gsi.range_key, type = gsi.range_key_type }] : [] if gsi.range_key != null && gsi.range_key != var.hash_key && (local.has_range_key ? gsi.range_key != var.range_key : true)])
  )
}
