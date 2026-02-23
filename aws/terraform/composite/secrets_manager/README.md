# Secrets Manager with KMS Composite Module

This composite module creates AWS Secrets Manager secrets with a dedicated KMS Customer Managed Key (CMK) for encryption.

## Features

- Dedicated KMS CMK for secrets encryption
- Automatic KMS key rotation enabled by default
- Multiple secrets encrypted with the same KMS key
- Support for secret rotation with Lambda
- Custom IAM policies for secrets
- Configurable recovery windows

## Architecture

This module combines:
- **KMS Module**: Creates a Customer Managed Key with automatic rotation
- **Secrets Manager Module**: Creates secrets encrypted with the KMS key

## Usage

### Basic Example

```hcl
module "secrets_with_kms" {
  source = "../../composite/secrets_manager_with_kms"

  project     = "myapp"
  environment = "prod"
  
  secrets = {
    database = {
      description = "Database credentials"
      secret_key_value = {
        username = "admin"
        password = "super-secret-password"
        host     = "db.example.com"
        port     = "5432"
      }
    }
    
    api_key = {
      description   = "Third-party API key"
      secret_string = "my-api-key-value"
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

### Example with Secret Rotation

```hcl
module "secrets_with_kms" {
  source = "../../composite/secrets_manager_with_kms"

  project     = "myapp"
  environment = "prod"
  
  secrets = {
    rds_credentials = {
      description = "RDS database credentials"
      secret_key_value = {
        username = "dbadmin"
        password = "initial-password"
        engine   = "postgres"
      }
      rotation = {
        enabled       = true
        lambda_arn    = "arn:aws:lambda:us-east-1:123456789012:function:rotate-secret"
        rotation_days = 30
      }
    }
  }
  
  kms_key_administrators = [
    "arn:aws:iam::123456789012:role/AdminRole"
  ]
  
  kms_key_users = [
    "arn:aws:iam::123456789012:role/AppRole"
  ]
}
```

### Example with Custom KMS Key Configuration

```hcl
module "secrets_with_kms" {
  source = "../../composite/secrets_manager_with_kms"

  project     = "myapp"
  environment = "prod"
  
  kms_key_suffix              = "app-secrets"
  kms_key_description         = "Encryption key for application secrets"
  kms_deletion_window_in_days = 7
  kms_enable_key_rotation     = true
  
  secrets = {
    app_config = {
      description = "Application configuration"
      secret_key_value = {
        api_url     = "https://api.example.com"
        timeout     = "30"
        max_retries = "3"
      }
      recovery_window_in_days = 7
    }
  }
}
```

### Example with Multiple Secrets and Custom Policies

```hcl
module "secrets_with_kms" {
  source = "../../composite/secrets_manager_with_kms"

  project     = "myapp"
  environment = "prod"
  
  secrets = {
    shared_secret = {
      description   = "Shared secret across accounts"
      secret_string = "my-shared-secret"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::987654321098:root"
            }
            Action   = "secretsmanager:GetSecretValue"
            Resource = "*"
          }
        ]
      })
    }
    
    internal_secret = {
      description = "Internal use only"
      secret_key_value = {
        key1 = "value1"
        key2 = "value2"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| kms | ../../service/kms | KMS Customer Managed Key |
| secrets_manager | ../../service/secrets_manager | Secrets Manager secrets |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| kms_key_suffix | Suffix for KMS key alias | `string` | `"secrets"` | no |
| kms_key_description | Description for KMS key | `string` | `"KMS key for Secrets Manager encryption"` | no |
| kms_deletion_window_in_days | KMS key deletion window | `number` | `30` | no |
| kms_enable_key_rotation | Enable KMS key rotation | `bool` | `true` | no |
| kms_key_administrators | IAM ARNs for key administrators | `list(string)` | `[]` | no |
| kms_key_users | IAM ARNs for key users | `list(string)` | `[]` | no |
| secrets | Map of secrets to create | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms_key_id | ID of the KMS key |
| kms_key_arn | ARN of the KMS key |
| kms_key_alias | Alias of the KMS key |
| secret_arns | Map of secret ARNs |
| secret_ids | Map of secret IDs |
| secret_names | Map of secret names |

## Benefits

### Security
- **Dedicated Encryption Key**: Each environment has its own KMS CMK
- **Automatic Key Rotation**: Keys are automatically rotated annually
- **Fine-grained Access Control**: Separate administrators and users for KMS keys
- **Secret Rotation**: Supports automatic secret rotation with Lambda functions

### Management
- **Centralized Secrets**: All secrets encrypted with the same key for easier management
- **Recovery Window**: Configurable deletion protection (7-30 days)
- **Custom Policies**: Support for cross-account access and custom permissions

### Compliance
- **Audit Trail**: All key usage logged in CloudWatch
- **Encryption at Rest**: All secrets encrypted with customer-managed keys
- **Key Deletion Protection**: Multi-day deletion window prevents accidental key deletion

## Secret Naming Convention

Secrets are named using the pattern: `{project}/{environment}/{secret_key}`

Example: `myapp/prod/database`, `myapp/dev/api_key`

## Notes

- The KMS key is shared across all secrets defined in the module
- Secret rotation requires a Lambda function to be created separately
- When using rotation, ensure the Lambda function has permission to use the KMS key
- The minimum recovery window is 7 days, maximum is 30 days
- KMS key deletion window ranges from 7 to 30 days
module "kms" {
  source = "../../service/kms"

  environment = var.environment
  project     = var.project
  key_suffix  = var.kms_key_suffix

  description             = var.kms_key_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  key_administrators      = var.kms_key_administrators
  key_users               = var.kms_key_users

  tags = var.tags
}

module "secrets_manager" {
  source = "../../service/secrets_manager"

  environment = var.environment
  project     = var.project

  secrets = {
    for k, v in var.secrets : k => merge(v, {
      kms_key_id = module.kms.key_id
    })
  }

  tags = var.tags
}

