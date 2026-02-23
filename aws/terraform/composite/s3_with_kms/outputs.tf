output "bucket_id" {
  description = "The name of the S3 bucket."
  value       = module.s3.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.s3.bucket_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key."
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key."
  value       = module.kms.key_arn
}

output "kms_alias_name" {
  description = "The alias name of the KMS key."
  value       = module.kms.alias_name
}
