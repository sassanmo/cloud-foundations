# AWS IAM Role Terraform Module

This module creates an IAM role with managed and inline policies, and optionally an instance profile for EC2.

## Features

- IAM role with custom assume role policy
- Attach multiple AWS managed policies
- Multiple inline policies support
- Optional EC2 instance profile
- Permissions boundary support
- Configurable session duration

## Usage

### Lambda Execution Role

```hcl
module "lambda_role" {
  source = "../../service/iam_role"

  project     = "myapp"
  environment = "prod"
  role_suffix = "lambda-execution"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  inline_policies = {
    dynamodb_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem"
          ]
          Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/my-table"
        }
      ]
    })
  }
  
  tags = {
    Team = "platform"
  }
}
```

### EC2 Instance Role

```hcl
module "ec2_role" {
  source = "../../service/iam_role"

  project     = "myapp"
  environment = "prod"
  role_suffix = "ec2-app"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  
  create_instance_profile = true
  
  tags = {
    Team = "platform"
  }
}

# Use in EC2 instance
resource "aws_instance" "app" {
  ami                  = "ami-12345678"
  instance_type        = "t3.micro"
  iam_instance_profile = module.ec2_role.instance_profile_name
}
```

### ECS Task Role

```hcl
module "ecs_task_role" {
  source = "../../service/iam_role"

  project     = "myapp"
  environment = "prod"
  role_suffix = "ecs-task"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  inline_policies = {
    s3_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
  }
}
```

### Cross-Account Role

```hcl
module "cross_account_role" {
  source = "../../service/iam_role"

  project     = "myapp"
  environment = "prod"
  role_suffix = "cross-account"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::987654321098:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "my-external-id"
          }
        }
      }
    ]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
  
  max_session_duration = 7200
}
```

### Role with Permissions Boundary

```hcl
module "developer_role" {
  source = "../../service/iam_role"

  project     = "myapp"
  environment = "dev"
  role_suffix = "developer"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
      }
    ]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
  
  permissions_boundary = "arn:aws:iam::123456789012:policy/DeveloperBoundary"
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
| role_suffix | Suffix for role name | `string` | n/a | yes |
| assume_role_policy | Assume role policy JSON | `string` | n/a | yes |
| description | Role description | `string` | `""` | no |
| managed_policy_arns | Managed policy ARNs | `list(string)` | `[]` | no |
| inline_policies | Inline policies | `map(string)` | `{}` | no |
| create_instance_profile | Create EC2 instance profile | `bool` | `false` | no |
| max_session_duration | Max session duration (seconds) | `number` | `3600` | no |
| permissions_boundary | Permissions boundary ARN | `string` | `null` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| instance_profile_arn | ARN of instance profile |
| instance_profile_name | Name of instance profile |

## Common AWS Managed Policies

- `arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`
- `arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole`
- `arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy`
- `arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy`
- `arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore`
- `arn:aws:iam::aws:policy/ReadOnlyAccess`
- `arn:aws:iam::aws:policy/PowerUserAccess`

## Notes

- Role naming: `{project}-{environment}-{role_suffix}`
- Use instance profiles for EC2 instances
- Use permissions boundaries to limit role permissions
- Default session duration is 1 hour (3600 seconds)
- Maximum session duration is 12 hours (43200 seconds)
- For multiple roles, call this module multiple times with different `role_suffix` values

