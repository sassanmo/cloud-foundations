# AWS VPC Terraform Module

This module creates a complete AWS VPC with public, private, and database subnets, NAT gateways, VPC endpoints, and flow logs.

## Features

- VPC with customizable CIDR block
- Public subnets with Internet Gateway
- Private subnets with NAT Gateway
- Database subnets (isolated)
- Multi-AZ support with flexible NAT Gateway configuration
- S3 and DynamoDB VPC endpoints (gateway endpoints)
- VPC Flow Logs with CloudWatch integration
- DNS hostnames and DNS support enabled by default

## Usage

### Basic VPC with Public and Private Subnets

```hcl
module "vpc" {
  source = "../../service/vpc"

  project     = "myapp"
  environment = "prod"
  
  vpc_cidr = "10.0.0.0/16"
  
  public_subnets = {
    az1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    az2 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
  
  private_subnets = {
    az1 = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1a"
    }
    az2 = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "us-east-1b"
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

### VPC with Multi-AZ NAT Gateways

```hcl
module "vpc" {
  source = "../../service/vpc"

  project     = "myapp"
  environment = "prod"
  
  vpc_cidr = "10.0.0.0/16"
  
  public_subnets = {
    az1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    az2 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
  
  private_subnets = {
    az1 = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1a"
      nat_gateway_key   = "az1"
    }
    az2 = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "us-east-1b"
      nat_gateway_key   = "az2"
    }
  }
  
  enable_nat_gateway = true
  nat_gateway_configuration = {
    az1 = {
      subnet_key = "az1"
    }
    az2 = {
      subnet_key = "az2"
    }
  }
}
```

### Complete VPC with Database Subnets

```hcl
module "vpc" {
  source = "../../service/vpc"

  project     = "myapp"
  environment = "prod"
  
  vpc_cidr = "10.0.0.0/16"
  
  public_subnets = {
    az1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    az2 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
  
  private_subnets = {
    az1 = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1a"
    }
    az2 = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "us-east-1b"
    }
  }
  
  database_subnets = {
    az1 = {
      cidr_block        = "10.0.21.0/24"
      availability_zone = "us-east-1a"
    }
    az2 = {
      cidr_block        = "10.0.22.0/24"
      availability_zone = "us-east-1b"
    }
  }
  
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  enable_flow_logs         = true
  flow_logs_traffic_type   = "ALL"
}
```

### VPC Without NAT Gateway (Cost Optimization)

```hcl
module "vpc" {
  source = "../../service/vpc"

  project     = "myapp"
  environment = "dev"
  
  vpc_cidr = "10.0.0.0/16"
  
  public_subnets = {
    az1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
  }
  
  private_subnets = {
    az1 = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1a"
    }
  }
  
  enable_nat_gateway = false
  enable_flow_logs   = false
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
| vpc_cidr | CIDR block for VPC | `string` | n/a | yes |
| public_subnets | Map of public subnets | `map(object)` | `{}` | no |
| private_subnets | Map of private subnets | `map(object)` | `{}` | no |
| database_subnets | Map of database subnets | `map(object)` | `{}` | no |
| enable_nat_gateway | Enable NAT Gateway | `bool` | `true` | no |
| nat_gateway_configuration | NAT Gateway config | `map(object)` | See variables.tf | no |
| enable_s3_endpoint | Enable S3 VPC endpoint | `bool` | `true` | no |
| enable_dynamodb_endpoint | Enable DynamoDB endpoint | `bool` | `true` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `true` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_arn | ARN of the VPC |
| public_subnet_ids | Map of public subnet IDs |
| private_subnet_ids | Map of private subnet IDs |
| database_subnet_ids | Map of database subnet IDs |
| nat_gateway_ids | Map of NAT Gateway IDs |
| nat_gateway_public_ips | Map of NAT Gateway public IPs |

## Network Design

### Subnet Types

- **Public Subnets**: Direct route to Internet Gateway, suitable for ALB, NAT Gateway
- **Private Subnets**: Route through NAT Gateway, suitable for application servers, ECS tasks
- **Database Subnets**: No internet access, isolated for RDS, ElastiCache, etc.

### NAT Gateway Strategies

**Single NAT Gateway (Cost-optimized)**:
```hcl
nat_gateway_configuration = {
  default = {
    subnet_key = "az1"
  }
}
```

**Multi-AZ NAT Gateways (High Availability)**:
```hcl
nat_gateway_configuration = {
  az1 = { subnet_key = "az1" }
  az2 = { subnet_key = "az2" }
}
```

### VPC Endpoints

- **S3 Endpoint**: Gateway endpoint for private S3 access (no data transfer charges)
- **DynamoDB Endpoint**: Gateway endpoint for private DynamoDB access

## Best Practices

- Use at least 2 availability zones for high availability
- Enable VPC Flow Logs for security and troubleshooting
- Use VPC endpoints to reduce NAT Gateway data transfer costs
- Separate database subnets for network isolation
- Use /24 subnets for flexibility (251 usable IPs per subnet)

## Notes

- VPC naming pattern: `{project}-{environment}-{vpc_suffix}`
- NAT Gateways incur hourly charges and data transfer costs
- VPC endpoints (S3, DynamoDB) are free
- Flow logs are stored in CloudWatch Logs with configurable retention
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, { Name = local.vpc_name })
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(var.tags, { 
    Name = "${local.vpc_name}-public-${each.key}"
    Type = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(var.tags, { 
    Name = "${local.vpc_name}-private-${each.key}"
    Type = "private"
  })
}

resource "aws_subnet" "database" {
  for_each = var.database_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(var.tags, { 
    Name = "${local.vpc_name}-database-${each.key}"
    Type = "database"
  })
}

resource "aws_internet_gateway" "this" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.vpc_name}-igw" })
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? var.nat_gateway_configuration : {}

  domain = "vpc"

  tags = merge(var.tags, { Name = "${local.vpc_name}-nat-eip-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? var.nat_gateway_configuration : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value.subnet_key].id

  tags = merge(var.tags, { Name = "${local.vpc_name}-nat-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.vpc_name}-public-rt" })
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  for_each = var.enable_nat_gateway ? var.nat_gateway_configuration : { default = {} }

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.vpc_name}-private-rt-${each.key}" })
}

resource "aws_route" "private_nat_gateway" {
  for_each = var.enable_nat_gateway ? var.nat_gateway_configuration : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[var.enable_nat_gateway ? lookup(each.value, "nat_gateway_key", "default") : "default"].id
}

resource "aws_route_table" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.vpc_name}-database-rt" })
}

resource "aws_route_table_association" "database" {
  for_each = var.database_subnets

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[0].id
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(var.tags, { Name = "${local.vpc_name}-s3-endpoint" })
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  for_each = var.enable_s3_endpoint && var.enable_nat_gateway ? var.nat_gateway_configuration : {}

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.private[each.key].id
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"

  tags = merge(var.tags, { Name = "${local.vpc_name}-dynamodb-endpoint" })
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_private" {
  for_each = var.enable_dynamodb_endpoint && var.enable_nat_gateway ? var.nat_gateway_configuration : {}

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = aws_route_table.private[each.key].id
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = var.flow_logs_traffic_type
  vpc_id          = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.vpc_name}-flow-logs" })
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${local.vpc_name}/flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(var.tags, { Name = "${local.vpc_name}-flow-logs" })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name               = "${local.vpc_name}-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role[0].json

  tags = merge(var.tags, { Name = "${local.vpc_name}-flow-logs-role" })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name   = "${local.vpc_name}-flow-logs-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs_policy[0].json
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

