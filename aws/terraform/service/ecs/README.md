# AWS ECS Terraform Module

This module creates AWS ECS resources including clusters, task definitions, and services.

## Features

- ECS cluster with Container Insights
- Support for Fargate and EC2 launch types
- Task definitions with container configurations
- ECS services with load balancer integration
- Service discovery support
- CloudWatch log groups for container logs
- IAM roles for task execution
- Support for EFS volumes

## Usage

```hcl
module "ecs" {
  source = "../../service/ecs"

  project     = "myapp"
  environment = "prod"
  
  task_definitions = {
    web = {
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
              "awslogs-group"         = "/ecs/myapp-prod-cluster/web"
              "awslogs-region"        = "us-east-1"
              "awslogs-stream-prefix" = "ecs"
            }
          }
        }
      ]
    }
  }
  
  services = {
    web = {
      task_definition_key = "web"
      desired_count       = 2
      network_configuration = {
        subnets         = ["subnet-12345", "subnet-67890"]
        security_groups = ["sg-12345"]
      }
      load_balancers = [
        {
          target_group_arn = aws_lb_target_group.web.arn
          container_name   = "web"
          container_port   = 80
        }
      ]
    }
  }
  
  log_groups = {
    web = {
      retention_days = 30
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

## Examples

### ECS with Fargate Spot

```hcl
module "ecs" {
  source = "../../service/ecs"

  project     = "myapp"
  environment = "prod"
  
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
  
  task_definitions = {
    worker = {
      cpu    = "512"
      memory = "1024"
      container_definitions = [
        {
          name  = "worker"
          image = "myapp/worker:latest"
        }
      ]
    }
  }
  
  services = {
    worker = {
      task_definition_key = "worker"
      desired_count       = 5
      network_configuration = {
        subnets         = ["subnet-12345"]
        security_groups = ["sg-12345"]
      }
    }
  }
}
```

### ECS with EFS Volume

```hcl
module "ecs" {
  source = "../../service/ecs"

  project     = "myapp"
  environment = "prod"
  
  task_definitions = {
    app = {
      cpu    = "256"
      memory = "512"
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
            file_system_id = "fs-12345678"
            root_directory = "/data"
          }
        }
      ]
    }
  }
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
| enable_container_insights | Enable Container Insights | `bool` | `true` | no |
| task_definitions | Map of task definitions | `map(object)` | `{}` | no |
| services | Map of ECS services | `map(object)` | `{}` | no |
| log_groups | Map of log groups | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| task_definition_arns | Map of task definition ARNs |
| service_ids | Map of ECS service IDs |
| execution_role_arn | ARN of the execution role |
resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, { Name = local.cluster_name })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(var.capacity_providers) > 0 ? 1 : 0

  cluster_name = aws_ecs_cluster.this.name
  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  for_each = var.task_definitions

  family                   = "${local.cluster_name}-${each.key}"
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = each.value.execution_role_arn != null ? each.value.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn            = each.value.task_role_arn

  container_definitions = jsonencode(each.value.container_definitions)

  dynamic "volume" {
    for_each = each.value.volumes != null ? each.value.volumes : []
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

  tags = merge(var.tags, { Name = "${local.cluster_name}-${each.key}" })
}

resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = "${local.cluster_name}-${each.key}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.value.task_definition_key].arn
  desired_count   = each.value.desired_count
  launch_type     = each.value.launch_type

  dynamic "network_configuration" {
    for_each = each.value.network_configuration != null ? [each.value.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      security_groups  = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = each.value.load_balancers != null ? each.value.load_balancers : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = each.value.service_registry_arn != null ? [1] : []
    content {
      registry_arn = each.value.service_registry_arn
    }
  }

  health_check_grace_period_seconds = each.value.health_check_grace_period_seconds
  enable_execute_command            = each.value.enable_execute_command

  tags = merge(var.tags, { Name = "${local.cluster_name}-${each.key}" })
}

resource "aws_iam_role" "execution" {
  count = var.create_execution_role ? 1 : 0

  name               = "${local.cluster_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role[0].json

  tags = merge(var.tags, { Name = "${local.cluster_name}-execution-role" })
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

  name   = "${local.cluster_name}-execution-custom"
  role   = aws_iam_role.execution[0].id
  policy = var.execution_role_custom_policy_json
}

resource "aws_cloudwatch_log_group" "ecs" {
  for_each = var.log_groups

  name              = "/ecs/${local.cluster_name}/${each.key}"
  retention_in_days = each.value.retention_days
  kms_key_id        = each.value.kms_key_id

  tags = merge(var.tags, { Name = "/ecs/${local.cluster_name}/${each.key}" })
}

