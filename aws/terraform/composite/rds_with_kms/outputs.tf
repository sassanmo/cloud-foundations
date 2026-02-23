output "db_instance_id" {
  description = "The RDS instance identifier."
  value       = module.rds.db_instance_id
}

output "db_instance_endpoint" {
  description = "The connection endpoint."
  value       = module.rds.db_instance_endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = module.rds.db_instance_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key."
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key."
  value       = module.kms.key_arn
}
