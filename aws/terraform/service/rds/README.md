# RDS Module

This module creates a secure AWS RDS instance following AWS best practices.

## Features

- Storage encryption enabled by default
- Multi-AZ deployment enabled by default
- Automatic storage autoscaling
- Deletion protection enabled by default
- Final snapshot on deletion
- Automated backups with configurable retention

## Usage

```hcl
module "rds" {
  source = "../../service/rds"

  identifier           = "my-postgres-db"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.medium"
  username             = "dbadmin"
  password             = var.db_password  # Use AWS Secrets Manager in production
  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | Identifier for the RDS instance. | `string` | n/a | yes |
| username | Master username. | `string` | n/a | yes |
| password | Master password. | `string` | n/a | yes |
| db_subnet_group_name | Name of the DB subnet group. | `string` | n/a | yes |
| engine | Database engine. | `string` | `"postgres"` | no |
| engine_version | Database engine version. | `string` | `"15.4"` | no |
| instance_class | Instance class. | `string` | `"db.t3.medium"` | no |
| allocated_storage | Allocated storage in GiB. | `number` | `20` | no |
| max_allocated_storage | Max storage for autoscaling. | `number` | `100` | no |
| multi_az | Enable Multi-AZ deployment. | `bool` | `true` | no |
| storage_encrypted | Enable storage encryption. | `bool` | `true` | no |
| kms_key_id | KMS key ARN for encryption. | `string` | `""` | no |
| backup_retention_period | Backup retention in days. | `number` | `7` | no |
| deletion_protection | Enable deletion protection. | `bool` | `true` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The RDS instance identifier. |
| db_instance_arn | The ARN of the RDS instance. |
| db_instance_endpoint | The connection endpoint. |
| db_instance_address | The hostname. |
| db_instance_port | The port. |
| db_name | The database name. |
