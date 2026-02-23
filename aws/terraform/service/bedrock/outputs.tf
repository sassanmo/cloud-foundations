# Bedrock Agent Outputs
output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = var.agent_name != null ? aws_bedrockagent_agent.this[0].id : null
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = var.agent_name != null ? aws_bedrockagent_agent.this[0].agent_arn : null
}

output "agent_name" {
  description = "Name of the Bedrock agent"
  value       = var.agent_name != null ? aws_bedrockagent_agent.this[0].agent_name : null
}

# Bedrock Knowledge Base Outputs
output "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base"
  value       = var.knowledge_base_name != null ? aws_bedrockagent_knowledge_base.this[0].id : null
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock knowledge base"
  value       = var.knowledge_base_name != null ? aws_bedrockagent_knowledge_base.this[0].arn : null
}

output "knowledge_base_name" {
  description = "Name of the Bedrock knowledge base"
  value       = var.knowledge_base_name != null ? aws_bedrockagent_knowledge_base.this[0].name : null
}

# Bedrock Guardrail Outputs
output "guardrail_id" {
  description = "ID of the Bedrock guardrail"
  value       = var.guardrail_name != null ? aws_bedrock_guardrail.this[0].id : null
}

output "guardrail_arn" {
  description = "ARN of the Bedrock guardrail"
  value       = var.guardrail_name != null ? aws_bedrock_guardrail.this[0].guardrail_arn : null
}

output "guardrail_name" {
  description = "Name of the Bedrock guardrail"
  value       = var.guardrail_name != null ? aws_bedrock_guardrail.this[0].name : null
}
