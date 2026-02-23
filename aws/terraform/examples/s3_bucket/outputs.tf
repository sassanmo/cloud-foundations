output "simple_bucket_arn" {
  description = "ARN of the simple S3 bucket."
  value       = module.s3_bucket_simple.bucket_arn
}

output "kms_bucket_arn" {
  description = "ARN of the KMS-encrypted S3 bucket."
  value       = module.s3_bucket_kms.bucket_arn
}
