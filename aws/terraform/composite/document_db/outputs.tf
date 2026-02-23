output "cluster_arn" {
  description = "DocumentDB cluster ARN"
  value       = module.document_db.cluster_arn
}

output "cluster_identifier" {
  description = "DocumentDB cluster identifier"
  value       = module.document_db.cluster_identifier
}

output "cluster_resource_id" {
  description = "DocumentDB cluster resource ID"
  value       = module.document_db.cluster_resource_id
}

output "endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = module.document_db.endpoint
}

output "reader_endpoint" {
  description = "DocumentDB cluster reader endpoint"
  value       = module.document_db.reader_endpoint
}

output "port" {
  description = "DocumentDB cluster port"
  value       = module.document_db.port
}

output "master_username" {
  description = "The master username for the database"
  value       = module.document_db.master_username
  sensitive   = true
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = module.kms.key_id
}
