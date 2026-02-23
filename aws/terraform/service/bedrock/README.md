# Bedrock Service Module

This module provides a reusable Terraform configuration for deploying AWS Bedrock resources including Agents, Knowledge Bases, and Guardrails.

## Features

- **Bedrock Agents**: Create AI agents with foundation models
- **Knowledge Bases**: Set up vector stores with OpenSearch Serverless or Pinecone
- **Guardrails**: Configure content filtering and safety policies
- **IAM Role Management**: Optionally create IAM roles with appropriate permissions
- **Flexible Configuration**: Support for multiple vector store backends

## Usage

### Basic Bedrock Agent

```hcl
module "bedrock_agent" {
  source = "./service/bedrock"

  environment = "prod"
  project     = "myapp"

  agent_name          = "customer-support"
  foundation_model    = "anthropic.claude-v2"
  agent_instruction   = "You are a helpful customer support agent."
  create_agent_role   = true
}
```

### Bedrock Knowledge Base with OpenSearch Serverless

```hcl
module "bedrock_kb" {
  source = "./service/bedrock"

  environment = "prod"
  project     = "myapp"

  knowledge_base_name       = "product-docs"
  knowledge_base_description = "Product documentation knowledge base"
  create_knowledge_base_role = true
  embedding_model_arn       = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"

  vector_store_configuration = {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration = {
      collection_arn    = "arn:aws:aoss:us-east-1:123456789012:collection/xyz"
      vector_index_name = "bedrock-index"
      field_mapping = {
        vector_field   = "vector"
        text_field     = "text"
        metadata_field = "metadata"
      }
    }
  }
}
```

### Bedrock Guardrail

```hcl
module "bedrock_guardrail" {
  source = "./service/bedrock"

  environment = "prod"
  project     = "myapp"

  guardrail_name               = "content-filter"
  guardrail_description        = "Content filtering guardrail"
  blocked_input_messaging      = "Your input contains inappropriate content."
  blocked_outputs_messaging    = "The response contains inappropriate content."

  content_policy_config = [
    {
      type            = "SEXUAL"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    },
    {
      type            = "VIOLENCE"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
  ]

  topic_policy_config = [
    {
      name       = "financial_advice"
      definition = "Financial advice and investment recommendations"
      examples   = ["Should I invest in stocks?", "What's the best cryptocurrency?"]
      type       = "DENY"
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| agent_name | Name suffix for the Bedrock agent | `string` | `null` | no |
| foundation_model | Foundation model identifier | `string` | `"anthropic.claude-v2"` | no |
| knowledge_base_name | Name suffix for the knowledge base | `string` | `null` | no |
| guardrail_name | Name suffix for the guardrail | `string` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent_id | ID of the Bedrock agent |
| agent_arn | ARN of the Bedrock agent |
| knowledge_base_id | ID of the knowledge base |
| guardrail_id | ID of the guardrail |

## Notes

- AWS Bedrock requires AWS Provider version >= 5.0
- Bedrock services have specific regional availability
- Knowledge bases require a vector store (OpenSearch Serverless or Pinecone)
- Agents may take several minutes to prepare
# Bedrock Agent IAM Role
resource "aws_iam_role" "agent" {
  count = var.create_agent_role && var.agent_name != null ? 1 : 0

  name = "${local.agent_name}-role"

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
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${local.agent_name}-role"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy" "agent" {
  count = var.create_agent_role && var.agent_name != null ? 1 : 0

  name = "${local.agent_name}-policy"
  role = aws_iam_role.agent[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.foundation_model}"
        ]
      }
    ]
  })
}

# Bedrock Agent
resource "aws_bedrockagent_agent" "this" {
  count = var.agent_name != null ? 1 : 0

  agent_name              = local.agent_name
  agent_resource_role_arn = var.create_agent_role ? aws_iam_role.agent[0].arn : var.agent_role_arn
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

# Bedrock Knowledge Base IAM Role
resource "aws_iam_role" "knowledge_base" {
  count = var.create_knowledge_base_role && var.knowledge_base_name != null ? 1 : 0

  name = "${local.knowledge_base_name}-role"

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
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${local.knowledge_base_name}-role"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy" "knowledge_base" {
  count = var.create_knowledge_base_role && var.knowledge_base_name != null ? 1 : 0

  name = "${local.knowledge_base_name}-policy"
  role = aws_iam_role.knowledge_base[0].id

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
}

# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "this" {
  count = var.knowledge_base_name != null ? 1 : 0

  name        = local.knowledge_base_name
  description = var.knowledge_base_description
  role_arn    = var.create_knowledge_base_role ? aws_iam_role.knowledge_base[0].arn : var.knowledge_base_role_arn

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

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

