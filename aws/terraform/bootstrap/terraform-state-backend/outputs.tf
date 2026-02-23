output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = module.s3.bucket_arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = var.region
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = module.dynamodb.table_arn
}

output "kms_key_id" {
  description = "ID of the KMS key for state encryption"
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for state encryption"
  value       = module.kms.key_arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key"
  value       = module.kms.alias_name
}

output "backend_config" {
  description = "Backend configuration for use in other Terraform projects"
  value = {
    bucket         = module.s3.bucket_id
    region         = var.region
    dynamodb_table = module.dynamodb.table_name
    encrypt        = true
    kms_key_id     = module.kms.key_id
  }
}

# IAM Policy Outputs
output "admin_policy_arn" {
  description = "ARN of the IAM policy for Terraform state admin access"
  value       = var.create_iam_policies ? aws_iam_policy.terraform_state_admin[0].arn : null
}

output "readonly_policy_arn" {
  description = "ARN of the IAM policy for Terraform state read-only access"
  value       = var.create_iam_policies ? aws_iam_policy.terraform_state_read_only[0].arn : null
}

# CloudTrail Outputs
output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.terraform_state[0].name : null
}

output "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = var.enable_cloudtrail ? module.cloudtrail_bucket[0].bucket_id : null
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = var.enable_cloudtrail ? module.cloudtrail_bucket[0].bucket_arn : null
}

# Replication Outputs
output "replication_bucket_name" {
  description = "Name of the S3 replication bucket"
  value       = var.enable_replication ? module.replication_bucket[0].bucket_id : null
}

output "replication_bucket_arn" {
  description = "ARN of the S3 replication bucket"
  value       = var.enable_replication ? module.replication_bucket[0].bucket_arn : null
}

output "replication_kms_key_id" {
  description = "ID of the KMS key for replication"
  value       = var.enable_replication ? module.kms_replication[0].key_id : null
}

output "replication_kms_key_arn" {
  description = "ARN of the KMS key for replication"
  value       = var.enable_replication ? module.kms_replication[0].key_arn : null
}

