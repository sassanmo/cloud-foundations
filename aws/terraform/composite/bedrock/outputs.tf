output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.kms.key_id
}

output "agent_iam_role_arn" {
  description = "ARN of the Bedrock agent IAM role"
  value       = var.agent_name != null ? module.agent_iam_role[0].role_arn : null
}

output "knowledge_base_iam_role_arn" {
  description = "ARN of the Bedrock knowledge base IAM role"
  value       = var.knowledge_base_name != null ? module.knowledge_base_iam_role[0].role_arn : null
}

output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = module.bedrock.agent_id
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = module.bedrock.agent_arn
}

output "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base"
  value       = module.bedrock.knowledge_base_id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock knowledge base"
  value       = module.bedrock.knowledge_base_arn
}

output "guardrail_id" {
  description = "ID of the Bedrock guardrail"
  value       = module.bedrock.guardrail_id
}

output "guardrail_arn" {
  description = "ARN of the Bedrock guardrail"
  value       = module.bedrock.guardrail_arn
}
