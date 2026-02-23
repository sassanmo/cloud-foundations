# ECR Service Module

This module provides a reusable Terraform configuration for deploying AWS Elastic Container Registry (ECR) repositories.

## Features

- **Container Registry**: Store and manage Docker container images
- **Image Scanning**: Automatic vulnerability scanning on push
- **Encryption**: Support for AES256 and KMS encryption
- **Lifecycle Policies**: Automatic cleanup of old images
- **Cross-Account Access**: Share repositories across AWS accounts
- **Tag Mutability**: Control whether image tags can be overwritten

## Usage

### Basic ECR Repository

```hcl
module "ecr" {
  source = "./service/ecr"

  environment       = "prod"
  project           = "myapp"
  repository_name   = "backend-api"
  scan_on_push      = true
  max_image_count   = 30
}
```

### ECR with KMS Encryption

```hcl
module "ecr" {
  source = "./service/ecr"

  environment       = "prod"
  project           = "myapp"
  repository_name   = "backend-api"
  encryption_type   = "KMS"
  kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/abc-123"
  image_tag_mutability = "IMMUTABLE"
}
```

### ECR with Cross-Account Access

```hcl
module "ecr" {
  source = "./service/ecr"

  environment                = "prod"
  project                    = "myapp"
  repository_name            = "shared-image"
  enable_cross_account_access = true
  cross_account_ids          = ["123456789012", "987654321098"]
}
```

### ECR with Custom Lifecycle Policy

```hcl
module "ecr" {
  source = "./service/ecr"

  environment       = "prod"
  project           = "myapp"
  repository_name   = "backend-api"
  
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
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
| repository_name | ECR repository name | `string` | n/a | yes |
| scan_on_push | Enable image scanning | `bool` | `true` | no |
| max_image_count | Max images to retain | `number` | `30` | no |
| image_tag_mutability | Tag mutability | `string` | `"MUTABLE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_arn | ARN of the ECR repository |
| repository_url | URL of the ECR repository |
| repository_name | Name of the ECR repository |
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

