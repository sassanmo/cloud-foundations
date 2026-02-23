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

  tags = merge(
    var.tags,
    {
      Name        = local.task_family
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_ecs_service" "this" {
  count = var.create_service ? 1 : 0

  name            = local.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  enable_execute_command = var.enable_execute_command

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

  health_check_grace_period_seconds = length(var.load_balancers) > 0 ? var.health_check_grace_period_seconds : null

  tags = merge(
    var.tags,
    {
      Name        = local.service_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "execution" {
  count = var.create_execution_role ? 1 : 0

  name               = local.execution_role_name
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name        = local.execution_role_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

data "aws_iam_policy_document" "execution_assume_role" {
  count = var.create_execution_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "execution_ecs_task_execution" {
  count = var.create_execution_role ? 1 : 0

  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:${var.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_custom" {
  count = var.create_execution_role && var.execution_role_custom_policy_json != "" ? 1 : 0

  name   = "${local.execution_role_name}-custom"
  role   = aws_iam_role.execution[0].id
  policy = var.execution_role_custom_policy_json
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = local.log_group_name
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
