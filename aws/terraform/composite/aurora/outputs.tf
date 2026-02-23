output "cluster_arn" {
  description = "RDS Cluster ARN"
  value       = module.aurora.cluster_arn
}

output "cluster_id" {
  description = "RDS Cluster Identifier"
  value       = module.aurora.cluster_id
}

output "cluster_identifier" {
  description = "RDS Cluster Identifier"
  value       = module.aurora.cluster_identifier
}

output "cluster_resource_id" {
  description = "RDS Cluster Resource ID"
  value       = module.aurora.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.aurora.cluster_members
}

output "availability_zones" {
  description = "The availability zone of the RDS instance"
  value       = module.aurora.availability_zones
}

output "backup_retention_period" {
  description = "The backup retention period"
  value       = module.aurora.backup_retention_period
}

output "preferred_backup_window" {
  description = "The daily time range for backups"
  value       = module.aurora.preferred_backup_window
}

output "preferred_maintenance_window" {
  description = "The maintenance window"
  value       = module.aurora.preferred_maintenance_window
}

output "endpoint" {
  description = "RDS instance hostname"
  value       = module.aurora.endpoint
}

output "reader_endpoint" {
  description = "RDS instance hostname"
  value       = module.aurora.reader_endpoint
}

output "engine_version" {
  description = "The running version of the database"
  value       = module.aurora.engine_version
}

output "database_name" {
  description = "The database name"
  value       = module.aurora.database_name
}

output "port" {
  description = "The database port"
  value       = module.aurora.port
}

output "master_username" {
  description = "The master username for the database"
  value       = module.aurora.master_username
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
