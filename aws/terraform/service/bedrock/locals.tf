locals {
  agent_name           = var.agent_name != null ? "${var.project}-${var.environment}-${var.agent_name}" : null
  knowledge_base_name  = var.knowledge_base_name != null ? "${var.project}-${var.environment}-${var.knowledge_base_name}" : null
  guardrail_name       = var.guardrail_name != null ? "${var.project}-${var.environment}-${var.guardrail_name}" : null
}

