# KMS Key for Bedrock encryption (created without specific policy first)
module "kms" {
  source = "../../service/kms"

  account_id              = var.account_id
  region                  = var.region
  partition               = var.partition
  alias_name              = local.kms_alias_name
  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  # Initial policy allowing root access - will be updated below
  policy = local.initial_kms_policy

  tags = var.tags
}

# IAM Role for Bedrock Agent
module "agent_iam_role" {
  count  = var.agent_name != null ? 1 : 0
  source = "../../service/iam_role"

  account_id = var.account_id
  region     = var.region
  partition  = var.partition

  role_name        = "${local.agent_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${var.partition}:bedrock:${var.region}:${var.account_id}:agent/*"
          }
        }
      }
    ]
  })

  inline_policies = [{
    name = "${local.agent_name}-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "bedrock:InvokeModel"
          ]
          Resource = [
            "arn:${var.partition}:bedrock:${var.region}::foundation-model/${var.foundation_model}"
          ]
        }
      ]
    })
  }]

  tags = var.tags
}

# IAM Role for Bedrock Knowledge Base
module "knowledge_base_iam_role" {
  count  = var.knowledge_base_name != null ? 1 : 0
  source = "../../service/iam_role"

  account_id = var.account_id
  region     = var.region
  partition  = var.partition

  role_name        = "${local.knowledge_base_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${var.partition}:bedrock:${var.region}:${var.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })

  inline_policies = [{
    name = "${local.knowledge_base_name}-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "bedrock:InvokeModel"
          ]
          Resource = var.embedding_model_arn != null ? [var.embedding_model_arn] : ["*"]
        },
        {
          Effect = "Allow"
          Action = [
            "aoss:APIAccessAll"
          ]
          Resource = var.vector_store_configuration != null && var.vector_store_configuration.opensearch_serverless_configuration != null ? [
            var.vector_store_configuration.opensearch_serverless_configuration.collection_arn
          ] : ["*"]
        }
      ]
    })
  }]

  tags = var.tags
}

# Bedrock Service Module
module "bedrock" {
  source = "../../service/bedrock"

  environment = var.environment
  project     = var.project

  # Agent configuration
  agent_name                      = var.agent_name
  agent_description               = var.agent_description
  foundation_model                = var.foundation_model
  agent_instruction               = var.agent_instruction
  agent_role_arn                  = var.agent_name != null ? module.agent_iam_role[0].role_arn : null
  idle_session_ttl_in_seconds     = var.idle_session_ttl_in_seconds
  prepare_agent                   = var.prepare_agent

  # Knowledge Base configuration
  knowledge_base_name         = var.knowledge_base_name
  knowledge_base_description  = var.knowledge_base_description
  knowledge_base_role_arn     = var.knowledge_base_name != null ? module.knowledge_base_iam_role[0].role_arn : null
  embedding_model_arn         = var.embedding_model_arn
  vector_store_configuration  = var.vector_store_configuration

  # Guardrail configuration
  guardrail_name                         = var.guardrail_name
  guardrail_description                  = var.guardrail_description
  blocked_input_messaging                = var.blocked_input_messaging
  blocked_outputs_messaging              = var.blocked_outputs_messaging
  content_policy_config                  = var.content_policy_config
  topic_policy_config                    = var.topic_policy_config
  word_policy_config                     = var.word_policy_config
  sensitive_information_policy_config    = var.sensitive_information_policy_config
  kms_key_arn                           = module.kms.key_arn

  tags = var.tags
}
