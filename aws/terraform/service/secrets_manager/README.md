# AWS Secrets Manager Terraform Module

This module creates and manages a single AWS Secrets Manager secret with support for rotation, encryption, and policies.

## Features

- Single secret management
- KMS encryption support
- Automatic secret rotation with Lambda
- Custom secret policies
- Configurable recovery window
- Support for JSON and string secrets

## Usage

### Basic Secret with String Value

```hcl
module "api_key" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "api-key"
  
  description   = "Third-party API key"
  secret_string = "my-api-key-value"
  
  tags = {
    Team = "platform"
  }
}
```

### Secret with JSON Value

```hcl
module "database_credentials" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "database"
  
  description = "Database credentials"
  secret_key_value = {
    username = "admin"
    password = "super-secret-password"
    host     = "db.example.com"
    port     = "5432"
  }
  
  kms_key_id = aws_kms_key.secrets.id
  
  tags = {
    Team = "platform"
  }
}
```

### Secret with Rotation

```hcl
module "rds_password" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "rds-password"
  
  description = "RDS master password"
  secret_key_value = {
    username = "admin"
    password = "initial-password"
  }
  
  rotation = {
    enabled       = true
    lambda_arn    = aws_lambda_function.rotate.arn
    rotation_days = 30
  }
  
  tags = {
    Team = "database"
  }
}
```

### Secret with Custom Policy

```hcl
module "shared_secret" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "shared"
  
  description   = "Shared secret across accounts"
  secret_string = "my-secret-value"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Shared = "true"
  }
}
```

### Multiple Secrets (by calling module multiple times)

```hcl
module "database_secret" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "database"
  
  secret_key_value = {
    username = "admin"
    password = "db-password"
  }
}

module "api_secret" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "api-key"
  
  secret_string = "api-key-value"
}

module "cache_secret" {
  source = "../../service/secrets_manager"

  project       = "myapp"
  environment   = "prod"
  secret_suffix = "redis"
  
  secret_key_value = {
    host     = "redis.example.com"
    password = "redis-password"
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| secret_suffix | Suffix for the secret name | `string` | n/a | yes |
| description | Description of the secret | `string` | `""` | no |
| secret_string | Secret value as plain string | `string` | `null` | no |
| secret_key_value | Secret value as map (JSON) | `map(string)` | `null` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| recovery_window_in_days | Recovery window (7-30 days) | `number` | `30` | no |
| rotation | Rotation configuration | `object` | `null` | no |
| policy | Resource policy for the secret | `string` | `null` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_arn | ARN of the secret |
| secret_id | ID of the secret |
| secret_name | Name of the secret |
| secret_version_id | Version ID of the secret |

## Notes

- Secret is named with the pattern: `{project}/{environment}/{secret_suffix}`
- Either `secret_string` or `secret_key_value` must be provided (not both)
- When `secret_key_value` is provided, it's stored as a JSON string
- Use `secret_string` for plain text secrets
- Default recovery window is 30 days (minimum is 7 days)
- Secret rotation requires a Lambda function to perform the rotation
- To create multiple secrets, call this module multiple times with different `secret_suffix` values
