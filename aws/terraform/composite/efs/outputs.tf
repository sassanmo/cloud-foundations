output "file_system_arn" {
  description = "Amazon Resource Name of the file system"
  value       = module.efs.file_system_arn
}

output "file_system_id" {
  description = "The ID that identifies the file system"
  value       = module.efs.file_system_id
}

output "file_system_dns_name" {
  description = "The DNS name for the filesystem"
  value       = module.efs.file_system_dns_name
}

output "mount_target_ids" {
  description = "List of IDs of the mount targets"
  value       = module.efs.mount_target_ids
}

output "mount_target_dns_names" {
  description = "List of DNS names of the mount targets"
  value       = module.efs.mount_target_dns_names
}

output "access_point_ids" {
  description = "List of IDs of the access points"
  value       = module.efs.access_point_ids
}

output "access_point_arns" {
  description = "List of ARNs of the access points"
  value       = module.efs.access_point_arns
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = module.kms.key_id
}
