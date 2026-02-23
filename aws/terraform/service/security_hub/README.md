# Security Hub Service Module

This module provides a reusable Terraform configuration for deploying AWS Security Hub with security standards and custom actions.

## Features

- **Security Hub Account**: Enable Security Hub in your AWS account
- **Security Standards**: Support for CIS, AWS Foundational, PCI DSS, and NIST standards
- **Custom Actions**: Create custom action targets for automated remediation
- **Member Accounts**: Invite member accounts in multi-account setups
- **Flexible Configuration**: Enable/disable specific standards as needed

## Usage

### Basic Security Hub

```hcl
module "security_hub" {
  source = "./service/security_hub"

  environment = "prod"
  project     = "myapp"

  enable_security_hub            = true
  enable_cis_standard            = true
  enable_aws_foundational_standard = true
}
```

### Security Hub with Custom Action

```hcl
module "security_hub" {
  source = "./service/security_hub"

  environment = "prod"
  project     = "myapp"

  enable_security_hub        = true
  action_target_name         = "send-to-sns"
  action_target_description  = "Send finding to SNS topic"
  action_target_identifier   = "SendToSNS"
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
| enable_security_hub | Enable Security Hub | `bool` | `true` | no |
| enable_cis_standard | Enable CIS standard | `bool` | `true` | no |
| enable_aws_foundational_standard | Enable AWS Foundational standard | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_hub_id | Security Hub account ID |
| security_hub_arn | Security Hub account ARN |
| cis_subscription_arn | CIS standard subscription ARN |
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

