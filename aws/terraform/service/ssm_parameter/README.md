# SSM Parameter Service Module

This module provides a reusable Terraform configuration for managing AWS Systems Manager (SSM) parameters.

## Features

- **Parameter Storage**: Store configuration data and secrets
- **Encryption Support**: SecureString type with KMS encryption
- **Hierarchical Naming**: Automatic path-based naming convention
- **Parameter Tiers**: Support for Standard, Advanced, and Intelligent-Tiering
- **Validation**: Optional pattern validation for parameter values

## Usage

### Basic SecureString Parameter

```hcl
module "db_password" {
  source = "./service/ssm_parameter"

  environment    = "prod"
  project        = "myapp"
  parameter_name = "database/password"
  type           = "SecureString"
  value          = "super-secret-password"
  description    = "Database password"
}
```

### String Parameter with KMS

```hcl
module "api_key" {
  source = "./service/ssm_parameter"

  environment    = "prod"
  project        = "myapp"
  parameter_name = "api/key"
  type           = "SecureString"
  value          = "api-key-value"
  kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/abc-123"
}
```

### Advanced Tier Parameter

```hcl
module "large_config" {
  source = "./service/ssm_parameter"

  environment    = "prod"
  project        = "myapp"
  parameter_name = "app/config"
  type           = "String"
  value          = file("large-config.json")
  tier           = "Advanced"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| parameter_name | Parameter name | `string` | n/a | yes |
| value | Parameter value | `string` | n/a | yes |
| type | Parameter type | `string` | `"SecureString"` | no |
| tier | Parameter tier | `string` | `"Standard"` | no |

## Outputs

| Name | Description |
|------|-------------|
| parameter_name | Name of the SSM parameter |
| parameter_arn | ARN of the SSM parameter |
| parameter_version | Version of the parameter |
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

