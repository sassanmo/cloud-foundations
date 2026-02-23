# ECR Example

This example demonstrates various configurations for AWS Elastic Container Registry (ECR) using the ECR service module.

## Overview

This example includes four different ECR repository configurations:

1. **Simple ECR Repository** - Basic repository with image scanning and lifecycle policy
2. **KMS-Encrypted Repository** - Repository with KMS encryption and immutable tags
3. **Custom Lifecycle Policy** - Repository with advanced lifecycle rules for different environments
4. **Cross-Account Access** - Repository configured for sharing across AWS accounts

## Features Demonstrated

- Basic ECR repository creation
- Image vulnerability scanning on push
- Default lifecycle policies based on image count
- Custom lifecycle policies with multiple rules
- KMS encryption for enhanced security
- Image tag mutability controls (MUTABLE vs IMMUTABLE)
- Cross-account repository access
- Tag-based image retention rules

## Prerequisites

- Terraform >= 1.0
- AWS Provider >= 4.0
- AWS credentials configured
- (For KMS example) KMS service module available

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan the Deployment

```bash
terraform plan
```

### Apply the Configuration

```bash
terraform apply
```

### Destroy Resources

```bash
terraform destroy
```

## Examples

### 1. Simple ECR Repository

Creates a basic ECR repository with:
- Image scanning enabled
- Maximum of 30 images retained
- AES256 encryption (default)

```hcl
module "ecr_simple" {
  source = "../../service/ecr"

  environment     = "example"
  project         = "myapp"
  repository_name = "backend-api"
  scan_on_push    = true
  max_image_count = 30
}
```

### 2. KMS-Encrypted Repository

Creates a repository with:
- KMS encryption for images
- Immutable image tags
- Linked to a KMS key

```hcl
module "ecr_kms" {
  source = "../../service/ecr"

  environment          = "example"
  project              = "myapp"
  repository_name      = "secure-api"
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "KMS"
  kms_key_arn          = module.kms_key.key_arn
}
```

### 3. Custom Lifecycle Policy

Creates a repository with environment-specific lifecycle rules:
- Keep last 10 production images
- Keep last 5 staging images
- Expire untagged images after 7 days

```hcl
module "ecr_custom_lifecycle" {
  source = "../../service/ecr"

  environment     = "example"
  project         = "myapp"
  repository_name = "frontend-app"
  
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

### 4. Cross-Account Access

Creates a repository that can be accessed from other AWS accounts:

```hcl
module "ecr_cross_account" {
  source = "../../service/ecr"

  environment                 = "example"
  project                     = "myapp"
  repository_name             = "shared-images"
  enable_cross_account_access = true
  cross_account_ids           = ["123456789012", "987654321098"]
}
```

## Outputs

The example provides several outputs for each repository:

- `ecr_simple_repository_url` - URL of the simple ECR repository
- `ecr_simple_repository_arn` - ARN of the simple ECR repository
- `ecr_kms_repository_url` - URL of the KMS-encrypted ECR repository
- `ecr_kms_repository_arn` - ARN of the KMS-encrypted ECR repository
- `ecr_custom_lifecycle_repository_url` - URL of the custom lifecycle ECR repository
- `ecr_custom_lifecycle_repository_arn` - ARN of the custom lifecycle ECR repository
- `ecr_cross_account_repository_url` - URL of the cross-account ECR repository
- `ecr_cross_account_repository_arn` - ARN of the cross-account ECR repository
- `kms_key_arn` - ARN of the KMS key used for encryption

## Using the Repositories

### Authenticate Docker to ECR

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
```

### Tag and Push an Image

```bash
# Tag your image
docker tag my-image:latest <repository_url>:latest

# Push to ECR
docker push <repository_url>:latest
```

### Pull an Image

```bash
docker pull <repository_url>:latest
```

## Notes

- **Cross-Account IDs**: Replace the example account IDs (`123456789012`, `987654321098`) with your actual AWS account IDs
- **KMS Keys**: The KMS example requires the KMS service module to be available
- **Lifecycle Policies**: Customize the lifecycle rules based on your retention requirements
- **Image Scanning**: Scan results can be viewed in the AWS ECR console or via AWS CLI
- **Costs**: Be aware of storage costs for retained images and data transfer costs

## Cleanup

When you're done with the examples, destroy the resources to avoid ongoing charges:

```bash
terraform destroy
```

Note: If repositories contain images and `force_delete` is not set to `true`, you'll need to manually delete the images first or add `force_delete = true` to the module configuration.

## Additional Resources

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)
- [ECR Repository Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html)
- [ECR Image Scanning](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html)

