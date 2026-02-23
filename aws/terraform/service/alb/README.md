# AWS Application Load Balancer Terraform Module

This module creates an AWS Application Load Balancer with target groups, listeners, and routing rules.

## Features

- Application Load Balancer (ALB)
- Multiple target groups with health checks
- HTTP and HTTPS listeners
- SSL/TLS certificate management
- Listener rules with path-based and host-based routing
- Access logging to S3
- Sticky sessions support
- WAF integration support

## Usage

```hcl
module "alb" {
  source = "../../service/alb"

  project     = "myapp"
  environment = "prod"
  
  vpc_id          = "vpc-12345678"
  subnets         = ["subnet-12345", "subnet-67890"]
  security_groups = ["sg-12345"]
  
  target_groups = {
    web = {
      port     = 80
      protocol = "HTTP"
      health_check = {
        path                = "/health"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  }
  
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "web"
      }
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

## Examples

### ALB with HTTPS Listener

```hcl
module "alb" {
  source = "../../service/alb"

  project     = "myapp"
  environment = "prod"
  
  vpc_id          = "vpc-12345678"
  subnets         = ["subnet-12345", "subnet-67890"]
  security_groups = ["sg-12345"]
  
  target_groups = {
    app = {
      port     = 8080
      protocol = "HTTP"
    }
  }
  
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type = "redirect"
        redirect = {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
      }
    }
    
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.main.arn
      default_action = {
        type             = "forward"
        target_group_key = "app"
      }
    }
  }
}
```

### ALB with Path-Based Routing

```hcl
module "alb" {
  source = "../../service/alb"

  project     = "myapp"
  environment = "prod"
  
  vpc_id          = "vpc-12345678"
  subnets         = ["subnet-12345", "subnet-67890"]
  security_groups = ["sg-12345"]
  
  target_groups = {
    api = {
      port = 8080
    }
    web = {
      port = 80
    }
  }
  
  listeners = {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.main.arn
      default_action = {
        type             = "forward"
        target_group_key = "web"
      }
    }
  }
  
  listener_rules = {
    api_route = {
      listener_key = "https"
      priority     = 100
      action = {
        type             = "forward"
        target_group_key = "api"
      }
      conditions = [
        {
          path_pattern = ["/api/*"]
        }
      ]
    }
  }
}
```

### ALB with Access Logs

```hcl
module "alb" {
  source = "../../service/alb"

  project     = "myapp"
  environment = "prod"
  
  vpc_id          = "vpc-12345678"
  subnets         = ["subnet-12345", "subnet-67890"]
  security_groups = ["sg-12345"]
  
  access_logs_enabled = true
  access_logs_bucket  = "my-alb-logs-bucket"
  access_logs_prefix  = "myapp/prod"
  
  target_groups = {
    app = {
      port = 80
    }
  }
  
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "app"
      }
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
| vpc_id | VPC ID | `string` | n/a | yes |
| subnets | List of subnet IDs | `list(string)` | n/a | yes |
| security_groups | List of security group IDs | `list(string)` | n/a | yes |
| internal | Whether ALB is internal | `bool` | `false` | no |
| target_groups | Map of target groups | `map(object)` | `{}` | no |
| listeners | Map of listeners | `map(object)` | `{}` | no |
| listener_rules | Map of listener rules | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name | DNS name of the ALB |
| alb_arn | ARN of the ALB |
| target_group_arns | Map of target group ARNs |
| listener_arns | Map of listener ARNs |
resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open            = var.enable_waf_fail_open
  idle_timeout                     = var.idle_timeout
  drop_invalid_header_fields       = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, { Name = local.alb_name })
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                 = "${local.alb_name}-${each.key}"
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = each.value.target_type
  deregistration_delay = each.value.deregistration_delay

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      timeout             = health_check.value.timeout
      interval            = health_check.value.interval
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      matcher             = health_check.value.matcher
    }
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []
    content {
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      enabled         = stickiness.value.enabled
    }
  }

  tags = merge(var.tags, each.value.tags, { Name = "${local.alb_name}-${each.key}" })
}

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "HTTPS" ? each.value.ssl_policy : null
  certificate_arn   = each.value.protocol == "HTTPS" ? each.value.certificate_arn : null

  default_action {
    type             = each.value.default_action.type
    target_group_arn = each.value.default_action.type == "forward" ? aws_lb_target_group.this[each.value.default_action.target_group_key].arn : null

    dynamic "redirect" {
      for_each = each.value.default_action.type == "redirect" ? [each.value.default_action.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.default_action.type == "fixed-response" ? [each.value.default_action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  tags = merge(var.tags, { Name = "${local.alb_name}-listener-${each.value.port}" })
}

resource "aws_lb_listener_certificate" "this" {
  for_each = var.additional_certificates

  listener_arn    = aws_lb_listener.this[each.value.listener_key].arn
  certificate_arn = each.value.certificate_arn
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = each.value.priority

  action {
    type             = each.value.action.type
    target_group_arn = each.value.action.type == "forward" ? aws_lb_target_group.this[each.value.action.target_group_key].arn : null

    dynamic "redirect" {
      for_each = each.value.action.type == "redirect" ? [each.value.action.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value
        }
      }

      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []
        content {
          values = host_header.value
        }
      }

      dynamic "http_header" {
        for_each = condition.value.http_header != null ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.http_request_method != null ? [condition.value.http_request_method] : []
        content {
          values = http_request_method.value
        }
      }
    }
  }

  tags = merge(var.tags, { Name = "${local.alb_name}-rule-${each.key}" })
}

