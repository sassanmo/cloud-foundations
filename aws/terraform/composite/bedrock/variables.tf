variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

# KMS Variables
variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for Bedrock encryption"
}

variable "kms_deletion_window_in_days" {
  description = "Number of days before the KMS key is deleted"
  type        = number
  default     = 7
}

variable "kms_enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

# Bedrock Agent Variables
variable "agent_name" {
  description = "Name suffix for the Bedrock agent"
  type        = string
  default     = null
}

variable "agent_description" {
  description = "Description of the Bedrock agent"
  type        = string
  default     = ""
}

variable "foundation_model" {
  description = "Foundation model identifier for the agent"
  type        = string
  default     = "anthropic.claude-v2"
}

variable "agent_instruction" {
  description = "Instructions for the Bedrock agent"
  type        = string
  default     = ""
}

variable "idle_session_ttl_in_seconds" {
  description = "Idle session TTL in seconds"
  type        = number
  default     = 600
}

variable "prepare_agent" {
  description = "Whether to prepare the agent"
  type        = bool
  default     = true
}

# Bedrock Knowledge Base Variables
variable "knowledge_base_name" {
  description = "Name suffix for the Bedrock knowledge base"
  type        = string
  default     = null
}

variable "knowledge_base_description" {
  description = "Description of the knowledge base"
  type        = string
  default     = ""
}

variable "embedding_model_arn" {
  description = "ARN of the embedding model"
  type        = string
  default     = null
}

variable "vector_store_configuration" {
  description = "Vector store configuration for knowledge base"
  type = object({
    type = string
    opensearch_serverless_configuration = optional(object({
      collection_arn    = string
      vector_index_name = string
      field_mapping = object({
        vector_field   = string
        text_field     = string
        metadata_field = string
      })
    }))
    pinecone_configuration = optional(object({
      connection_string = string
      credentials_secret_arn = string
      field_mapping = object({
        text_field     = string
        metadata_field = string
      })
    }))
  })
  default = null
}

# Bedrock Guardrail Variables
variable "guardrail_name" {
  description = "Name suffix for the Bedrock guardrail"
  type        = string
  default     = null
}

variable "guardrail_description" {
  description = "Description of the guardrail"
  type        = string
  default     = ""
}

variable "blocked_input_messaging" {
  description = "Message to return when input is blocked"
  type        = string
  default     = "Sorry, the model cannot answer this question."
}

variable "blocked_outputs_messaging" {
  description = "Message to return when output is blocked"
  type        = string
  default     = "Sorry, the model cannot provide a response."
}

variable "content_policy_config" {
  description = "Content policy configuration for guardrail"
  type = list(object({
    type              = string
    input_strength    = string
    output_strength   = string
  }))
  default = []
}

variable "topic_policy_config" {
  description = "Topic policy configuration for guardrail"
  type = list(object({
    name       = string
    definition = string
    examples   = list(string)
    type       = string
  }))
  default = []
}

variable "word_policy_config" {
  description = "Word policy configuration for guardrail"
  type = list(object({
    text = string
  }))
  default = []
}

variable "sensitive_information_policy_config" {
  description = "Sensitive information policy configuration"
  type = list(object({
    type   = string
    action = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
