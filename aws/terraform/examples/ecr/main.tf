module "ecr" {
  source = "../../service/ecr"

  region               = var.region
  environment          = var.environment
  project              = "myapp"
  repository_name      = "secure-api"
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "KMS"
  kms_key_arn          = module.kms_key.key_arn
  scan_on_push         = true

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
      },
      {
        rulePriority = 2
        description  = "Keep last 5 staging images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["staging"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Module      = "ecr"
  }
}

module "kms_key" {
  source = "../../service/kms"

  region      = var.region
  description = "KMS key for ECR encryption"
  alias_name  = "ecr-example-key"

  tags = {
    Environment = var.environment
    Module      = "kms"
  }
}
