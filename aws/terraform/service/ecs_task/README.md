# AWS ECS App Terraform Module

This module creates an ECS task definition and optionally an ECS service for deploying containerized applications.

## Features

- ECS task definition with container configurations
- Optional ECS service creation
- Automatic execution role creation with basic policies
- Support for Fargate and EC2 launch types
- EFS volume support for persistent storage
- Load balancer integration
- Service discovery support
- CloudWatch log group with configurable retention
- ECS Exec support for debugging

## Usage

### Basic Web Application

```hcl
module "web_app" {
  source = "../../service/ecs_app"

  project     = "myapp"
  environment = "prod"
  app_suffix  = "web"
  
  cluster_id = module.ecs_cluster.cluster_id
  
  cpu    = "256"
  memory = "512"
  
  container_definitions = [
    {
      name      = "web"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/myapp-prod/web"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ]
  
  network_configuration = {
    subnets         = module.vpc.private_subnet_ids
    security_groups = [aws_security_group.web.id]
  }
  
  load_balancers = [
    {
      target_group_arn = module.alb.target_group_arns["web"]
      container_name   = "web"
      container_port   = 80
    }
  ]
  
  tags = {
    Team = "platform"
  }
}
```

### Worker Application (No Service)

```hcl
module "worker_task" {
  source = "../../service/ecs_app"

  project     = "myapp"
  environment = "prod"
  app_suffix  = "worker"
  
  cluster_id = module.ecs_cluster.cluster_id
  
  cpu    = "512"
  memory = "1024"
  
  container_definitions = [
    {
      name  = "worker"
      image = "myapp/worker:latest"
      environment = [
        {
          name  = "QUEUE_URL"
          value = module.sqs.queue_url
        }
      ]
    }
  ]
  
  create_service = false  # Just create task definition
  
  execution_role_custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = module.sqs.queue_arn
      }
    ]
  })
}
```

### Application with EFS Volume

```hcl
module "app_with_storage" {
  source = "../../service/ecs_app"

  project     = "myapp"
  environment = "prod"
  app_suffix  = "storage-app"
  
  cluster_id = module.ecs_cluster.cluster_id
  
  cpu    = "512"
  memory = "1024"
  
  container_definitions = [
    {
      name  = "app"
      image = "myapp:latest"
      mountPoints = [
        {
          sourceVolume  = "efs-storage"
          containerPath = "/mnt/efs"
        }
      ]
    }
  ]
  
  volumes = [
    {
      name = "efs-storage"
      efs_volume_configuration = {
        file_system_id = aws_efs_file_system.app.id
        root_directory = "/data"
      }
    }
  ]
  
  network_configuration = {
    subnets         = module.vpc.private_subnet_ids
    security_groups = [aws_security_group.app.id]
  }
}
```

### Multiple Container Application

```hcl
module "multi_container_app" {
  source = "../../service/ecs_app"

  project     = "myapp"
  environment = "prod"
  app_suffix  = "api"
  
  cluster_id = module.ecs_cluster.cluster_id
  
  cpu    = "1024"
  memory = "2048"
  
  container_definitions = [
    {
      name      = "api"
      image     = "myapp/api:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    },
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      links = ["api"]
    }
  ]
  
  network_configuration = {
    subnets         = module.vpc.private_subnet_ids
    security_groups = [aws_security_group.api.id]
  }
  
  load_balancers = [
    {
      target_group_arn = module.alb.target_group_arns["api"]
      container_name   = "nginx"
      container_port   = 80
    }
  ]
}
```

### Application with ECS Exec Enabled

```hcl
module "debug_app" {
  source = "../../service/ecs_app"

  project     = "myapp"
  environment = "dev"
  app_suffix  = "debug-app"
  
  cluster_id = module.ecs_cluster.cluster_id
  
  cpu    = "256"
  memory = "512"
  
  container_definitions = [
    {
      name  = "app"
      image = "myapp:latest"
    }
  ]
  
  network_configuration = {
    subnets         = module.vpc.private_subnet_ids
    security_groups = [aws_security_group.app.id]
  }
  
  enable_execute_command = true  # Enable ECS Exec for debugging
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
| app_suffix | Suffix for app name | `string` | n/a | yes |
| cluster_id | ECS cluster ID | `string` | n/a | yes |
| cpu | CPU units | `string` | n/a | yes |
| memory | Memory in MiB | `string` | n/a | yes |
| container_definitions | Container definitions | `list(any)` | n/a | yes |
| network_mode | Network mode | `string` | `"awsvpc"` | no |
| requires_compatibilities | Launch types | `list(string)` | `["FARGATE"]` | no |
| create_service | Create ECS service | `bool` | `true` | no |
| desired_count | Desired task count | `number` | `1` | no |
| network_configuration | Network config | `object` | `null` | no |
| load_balancers | Load balancer configs | `list(object)` | `[]` | no |
| enable_execute_command | Enable ECS Exec | `bool` | `false` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| task_definition_arn | ARN of the task definition |
| task_definition_family | Family of the task definition |
| service_id | ID of the ECS service |
| service_name | Name of the ECS service |
| execution_role_arn | ARN of the execution role |
| log_group_name | Name of the CloudWatch log group |

## Fargate CPU and Memory Combinations

Valid combinations for Fargate:

| CPU | Memory Options |
|-----|----------------|
| 256 | 512, 1024, 2048 |
| 512 | 1024, 2048, 3072, 4096 |
| 1024 | 2048, 3072, 4096, 5120, 6144, 7168, 8192 |
| 2048 | 4096 to 16384 (1024 increments) |
| 4096 | 8192 to 30720 (1024 increments) |

## Notes

- Task definition naming: `{project}-{environment}-{app_suffix}`
- Service naming: `{project}-{environment}-{app_suffix}`
- Log group naming: `/ecs/{project}-{environment}/{app_suffix}`
- Use `create_service = false` for task definitions used with EventBridge or Step Functions
- ECS Exec requires additional IAM permissions on the task role
- For multiple apps, call this module multiple times with different `app_suffix` values
resource "aws_ecs_task_definition" "this" {
  family                   = local.task_family
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.create_execution_role ? aws_iam_role.execution[0].arn : var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode(var.container_definitions)

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port
        }
      }
    }
  }

  tags = merge(var.tags, { Name = local.task_family })
}

resource "aws_ecs_service" "this" {
  count = var.create_service ? 1 : 0

  name            = local.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      security_groups  = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registry_arn != null ? [1] : []
    content {
      registry_arn = var.service_registry_arn
    }
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_execute_command            = var.enable_execute_command

  tags = merge(var.tags, { Name = local.service_name })
}

resource "aws_iam_role" "execution" {
  count = var.create_execution_role ? 1 : 0

  name               = local.execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role[0].json

  tags = merge(var.tags, { Name = local.execution_role_name })
}

data "aws_iam_policy_document" "ecs_assume_role" {
  count = var.create_execution_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "execution" {
  count = var.create_execution_role ? 1 : 0

  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_custom" {
  count = var.create_execution_role && var.execution_role_custom_policy_json != "" ? 1 : 0

  name   = "${local.execution_role_name}-custom"
  role   = aws_iam_role.execution[0].id
  policy = var.execution_role_custom_policy_json
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(var.tags, { Name = local.log_group_name })
}

