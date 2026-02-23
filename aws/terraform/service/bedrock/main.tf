# Bedrock Agent
resource "aws_bedrockagent_agent" "this" {
  count = var.agent_name != null ? 1 : 0

  agent_name              = local.agent_name
  agent_resource_role_arn = var.agent_role_arn
  foundation_model        = var.foundation_model
  description             = var.agent_description
  instruction             = var.agent_instruction

  idle_session_ttl_in_seconds = var.idle_session_ttl_in_seconds
  prepare_agent               = var.prepare_agent

  tags = merge(
    var.tags,
    {
      Name        = local.agent_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "this" {
  count = var.knowledge_base_name != null ? 1 : 0

  name        = local.knowledge_base_name
  description = var.knowledge_base_description
  role_arn    = var.knowledge_base_role_arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
    }
  }

  dynamic "storage_configuration" {
    for_each = var.vector_store_configuration != null ? [1] : []
    content {
      type = var.vector_store_configuration.type

      dynamic "opensearch_serverless_configuration" {
        for_each = var.vector_store_configuration.opensearch_serverless_configuration != null ? [var.vector_store_configuration.opensearch_serverless_configuration] : []
        content {
          collection_arn    = opensearch_serverless_configuration.value.collection_arn
          vector_index_name = opensearch_serverless_configuration.value.vector_index_name
          field_mapping {
            vector_field   = opensearch_serverless_configuration.value.field_mapping.vector_field
            text_field     = opensearch_serverless_configuration.value.field_mapping.text_field
            metadata_field = opensearch_serverless_configuration.value.field_mapping.metadata_field
          }
        }
      }

      dynamic "pinecone_configuration" {
        for_each = var.vector_store_configuration.pinecone_configuration != null ? [var.vector_store_configuration.pinecone_configuration] : []
        content {
          connection_string      = pinecone_configuration.value.connection_string
          credentials_secret_arn = pinecone_configuration.value.credentials_secret_arn
          field_mapping {
            text_field     = pinecone_configuration.value.field_mapping.text_field
            metadata_field = pinecone_configuration.value.field_mapping.metadata_field
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = local.knowledge_base_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

# Bedrock Guardrail
resource "aws_bedrock_guardrail" "this" {
  count = var.guardrail_name != null ? 1 : 0

  name                      = local.guardrail_name
  description               = var.guardrail_description
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  kms_key_arn               = var.kms_key_arn

  dynamic "content_policy_config" {
    for_each = length(var.content_policy_config) > 0 ? [1] : []
    content {
      dynamic "filters_config" {
        for_each = var.content_policy_config
        content {
          type            = filters_config.value.type
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = length(var.topic_policy_config) > 0 ? [1] : []
    content {
      dynamic "topics_config" {
        for_each = var.topic_policy_config
        content {
          name       = topics_config.value.name
          definition = topics_config.value.definition
          examples   = topics_config.value.examples
          type       = topics_config.value.type
        }
      }
    }
  }

  dynamic "word_policy_config" {
    for_each = length(var.word_policy_config) > 0 ? [1] : []
    content {
      dynamic "words_config" {
        for_each = var.word_policy_config
        content {
          text = words_config.value.text
        }
      }
    }
  }

  dynamic "sensitive_information_policy_config" {
    for_each = length(var.sensitive_information_policy_config) > 0 ? [1] : []
    content {
      dynamic "pii_entities_config" {
        for_each = var.sensitive_information_policy_config
        content {
          type   = pii_entities_config.value.type
          action = pii_entities_config.value.action
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = local.guardrail_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

