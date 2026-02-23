output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamo_db.table_arn
}

output "table_id" {
  description = "Name of the DynamoDB table"
  value       = module.dynamo_db.table_id
}

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamo_db.table_name
}

output "stream_arn" {
  description = "The ARN of the Table Stream"
  value       = module.dynamo_db.stream_arn
}

output "stream_label" {
  description = "A timestamp, in ISO 8601 format, for this stream"
  value       = module.dynamo_db.stream_label
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = module.kms.key_id
}
