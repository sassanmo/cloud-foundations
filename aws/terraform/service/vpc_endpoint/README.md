# VPC Endpoint Service Module

This module creates and manages AWS VPC endpoints for secure connectivity to AWS services and VPC endpoint services. It can optionally create and manage security groups for Interface endpoints.

## Features

- Support for Gateway, Interface, and Gateway Load Balancer endpoints
- **Optional security group creation** for Interface endpoints with sensible defaults
- Configurable endpoint naming with environment and project tags
- Optional policy attachment for access control
- Support for private DNS resolution
- Flexible configuration for route tables (Gateway endpoints) and subnets/security groups (Interface endpoints)
- **Smart security group handling** - combines created and provided security groups

## Usage

### Gateway Endpoint (e.g., S3, DynamoDB)

```hcl
module "s3_endpoint" {
  source = "../../service/vpc_endpoint"

  project     = "my-project"
  environment = "dev"
  
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = [module.vpc.private_route_table_id]
  
  tags = {
    Service = "s3-endpoint"
  }
}
```

### Interface Endpoint with Auto-Created Security Group

```hcl
module "ec2_endpoint" {
  source = "../../service/vpc_endpoint"

  project     = "my-project"
  environment = "dev"
  
  vpc_id                = module.vpc.vpc_id
  service_name          = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [module.vpc.private_subnet_ids[0]]
  create_security_group = true
  allowed_cidr_blocks   = ["10.0.0.0/16"]  # Your VPC CIDR
  private_dns_enabled   = true
  
  tags = {
    Service = "ec2-endpoint"
  }
}
```

### Interface Endpoint with Existing Security Group

```hcl
module "lambda_endpoint" {
  source = "../../service/vpc_endpoint"

  project     = "my-project"
  environment = "dev"
  
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.us-east-1.lambda"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [module.vpc.private_subnet_ids[0]]
  security_group_ids  = [aws_security_group.existing.id]
  private_dns_enabled = true
  
  tags = {
    Service = "lambda-endpoint"
  }
}
```

### Interface Endpoint with Both Created and Existing Security Groups

```hcl
module "ssm_endpoint" {
  source = "../../service/vpc_endpoint"

  project     = "my-project"
  environment = "dev"
  
  vpc_id                = module.vpc.vpc_id
  service_name          = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [module.vpc.private_subnet_ids[0]]
  create_security_group = true
  security_group_ids    = [aws_security_group.additional.id]
  allowed_cidr_blocks   = ["10.0.0.0/16"]
  private_dns_enabled   = true
  
  tags = {
    Service = "ssm-endpoint"
  }
}
```

## Security Group Behavior

When `create_security_group = true` for Interface endpoints:

- Creates a security group with a descriptive name: `${project}-${environment}-${name}-sg`
- **Configurable Rules**: Uses `security_group_ingress_rules` and `security_group_egress_rules` variables
- **Sensible Defaults**: HTTPS (443) inbound from specified CIDR blocks, all TCP outbound
- **Flexible CIDR Blocks**: Rules can specify their own CIDR blocks or fall back to `allowed_cidr_blocks`
- **Combines with existing**: If you also specify `security_group_ids`, both the created and provided security groups are attached

### Default Security Group Rules

**Ingress (Inbound):**
- Port 443 (HTTPS) from RFC 1918 private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)

**Egress (Outbound):**
- All TCP traffic (0-65535) to anywhere (0.0.0.0/0)

### Custom Security Group Rules Examples

**Custom ingress rules:**
```hcl
module "ssm_endpoint" {
  source = "../../service/vpc_endpoint"
  
  # ...other config...
  create_security_group = true
  security_group_ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]  # Only from specific VPC
      description = "HTTPS from VPC"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp" 
      self        = true  # Allow traffic from same security group
      description = "HTTP from self"
    }
  ]
}
```

**Custom egress rules:**
```hcl
module "restricted_endpoint" {
  source = "../../service/vpc_endpoint"
  
  # ...other config...
  create_security_group = true
  security_group_egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]  # Only to private networks
      description = "HTTPS to private networks only"
    }
  ]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| **name** | **Name for the VPC endpoint** | `string` | `"endpoint"` | no |
| vpc_id | The ID of the VPC in which the endpoint will be used | `string` | n/a | yes |
| service_name | The service name for the VPC endpoint | `string` | n/a | yes |
| vpc_endpoint_type | The VPC endpoint type | `string` | `"Gateway"` | no |
| route_table_ids | One or more route table IDs (for Gateway endpoints) | `list(string)` | `null` | no |
| subnet_ids | The ID of one or more subnets (for Interface endpoints) | `list(string)` | `null` | no |
| security_group_ids | The ID of one or more security groups (for Interface endpoints) | `list(string)` | `null` | no |
| create_security_group | Whether to create a default security group for Interface endpoints | `bool` | `false` | no |
| allowed_cidr_blocks | List of CIDR blocks allowed to access the VPC endpoint | `list(string)` | `["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]` | no |
| **security_group_ingress_rules** | **List of ingress rules for the VPC endpoint security group** | `list(object)` | **HTTPS (443) from allowed CIDRs** | no |
| **security_group_egress_rules** | **List of egress rules for the VPC endpoint security group** | `list(object)` | **All TCP (0-65535) outbound** | no |
| policy | A policy to attach to the endpoint that controls access to the service | `string` | `null` | no |
| private_dns_enabled | Whether or not to associate a private hosted zone with the specified VPC | `bool` | `false` | no |
| auto_accept | Accept the VPC endpoint (same AWS account) | `bool` | `null` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_endpoint_id | The ID of the VPC endpoint |
| vpc_endpoint_arn | The Amazon Resource Name (ARN) of the VPC endpoint |
| vpc_endpoint_state | The state of the VPC endpoint |
| vpc_endpoint_prefix_list_id | The prefix list ID of the exposed AWS service |
| vpc_endpoint_cidr_blocks | The list of CIDR blocks for the exposed AWS service |
| vpc_endpoint_dns_entry | The DNS entries for the VPC Endpoint |
| vpc_endpoint_network_interface_ids | One or more network interfaces for the VPC Endpoint |
| endpoint_name | The name of the VPC endpoint |
| **security_group_id** | **The ID of the created security group (if created)** |
| **security_group_arn** | **The ARN of the created security group (if created)** |

## Common Service Names

### Gateway Endpoints
- S3: `com.amazonaws.region.s3`
- DynamoDB: `com.amazonaws.region.dynamodb`

### Interface Endpoints
- EC2: `com.amazonaws.region.ec2`
- Lambda: `com.amazonaws.region.lambda`
- SSM: `com.amazonaws.region.ssm`
- Secrets Manager: `com.amazonaws.region.secretsmanager`
- CloudWatch: `com.amazonaws.region.monitoring`
- KMS: `com.amazonaws.region.kms`

Replace `region` with your AWS region (e.g., `us-east-1`).
