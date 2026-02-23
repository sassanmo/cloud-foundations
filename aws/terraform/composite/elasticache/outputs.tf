output "cluster_id" {
  description = "The cache cluster identifier"
  value       = module.elasticache.cluster_id
}

output "cluster_address" {
  description = "The DNS name of the cache cluster without the port appended"
  value       = module.elasticache.cluster_address
}

output "configuration_endpoint" {
  description = "The configuration endpoint to allow host discovery"
  value       = module.elasticache.configuration_endpoint
}

output "cache_nodes" {
  description = "List of node objects including id, address, port and availability_zone"
  value       = module.elasticache.cache_nodes
}

output "port" {
  description = "The port number on which the cache accepts connections"
  value       = module.elasticache.port
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = module.kms.key_id
}
