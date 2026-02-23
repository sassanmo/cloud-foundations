output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.kms.key_arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key"
  value       = module.kms.key_alias
}

output "secret_arns" {
  description = "Map of secret ARNs"
  value       = { for k, v in module.secrets_manager : k => v.secret_arn }
}

output "secret_ids" {
  description = "Map of secret IDs"
  value       = { for k, v in module.secrets_manager : k => v.secret_id }
}

output "secret_names" {
  description = "Map of secret names"
  value       = { for k, v in module.secrets_manager : k => v.secret_name }
}
