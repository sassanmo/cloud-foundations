# AWS Aurora Terraform Module

This module creates an Amazon Aurora database cluster with multiple instances for high availability.

## Features

- Aurora PostgreSQL or MySQL cluster
- Multi-AZ deployment with read replicas
- Automatic backups and snapshots
- KMS encryption at rest
- Performance Insights enabled
- Enhanced monitoring
- CloudWatch Logs integration
- Serverless v2 support

## Usage

### Aurora PostgreSQL Cluster

```hcl
module "aurora_postgres" {
  source = "../../service/aurora"

  project     = "myapp"
  environment = "prod"
  
  engine         = "aurora-postgresql"
  engine_version = "15.3"
  instance_class = "db.r6g.large"
  instance_count = 2
  
  database_name   = "myapp"
  master_username = "admin"
  master_password = var.db_password
  
  subnet_ids             = module.vpc.database_subnet_ids
  vpc_security_group_ids = [aws_security_group.aurora.id]
  
  kms_key_id = module.kms.key_id
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  tags = {
    Team = "platform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| environment | Environment name | `string` | yes |
| project | Project name | `string` | yes |
| engine | Database engine | `string` | yes |
| engine_version | Engine version | `string` | yes |
| database_name | Database name | `string` | yes |
| master_username | Master username | `string` | yes |
| master_password | Master password | `string` | yes |
| subnet_ids | Subnet IDs | `list(string)` | yes |
| vpc_security_group_ids | Security group IDs | `list(string)` | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Writer endpoint |
| cluster_reader_endpoint | Reader endpoint |
| cluster_port | Database port |
resource "aws_rds_cluster" "this" {
  cluster_identifier      = local.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  engine_mode             = var.engine_mode
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  vpc_security_group_ids          = var.vpc_security_group_ids
  
  port = var.port
  
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  storage_encrypted   = true
  kms_key_id          = var.kms_key_id
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.cluster_identifier}-final-snapshot"
  
  apply_immediately = var.apply_immediately
  
  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverlessv2_scaling_configuration != null ? [var.serverlessv2_scaling_configuration] : []
    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }
  
  tags = merge(var.tags, { Name = local.cluster_identifier })
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${local.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  
  publicly_accessible = var.publicly_accessible
  
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  tags = merge(var.tags, { Name = "${local.cluster_identifier}-${count.index + 1}" })
}

resource "aws_db_subnet_group" "this" {
  name       = local.subnet_group_name
  subnet_ids = var.subnet_ids
  
  tags = merge(var.tags, { Name = local.subnet_group_name })
}

