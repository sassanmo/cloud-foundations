# ECR repository outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_registry_id" {
  description = "The registry ID where the repository was created"
  value       = module.ecr.registry_id
}

# KMS key output
output "kms_key_arn" {
  description = "ARN of the KMS key used for ECR encryption"
  value       = module.kms_key.key_arn
}

