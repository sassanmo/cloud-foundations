# RDS with KMS Composite Module

This composite module creates an RDS instance with a dedicated KMS Customer Managed Key (CMK) for storage encryption.

## Features

- Dedicated KMS CMK with automatic key rotation
- RDS instance with KMS storage encryption
- Multi-AZ deployment by default
- Deletion protection enabled by default

## Usage

```hcl
module "rds_with_kms" {
  source = "../../composite/rds_with_kms"

  identifier           = "my-postgres"
  username             = "dbadmin"
  password             = var.db_password
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
| kms_alias_name | KMS key alias. | `string` | `""` | no |
| multi_az | Enable Multi-AZ. | `bool` | `true` | no |
| deletion_protection | Enable deletion protection. | `bool` | `true` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The RDS instance identifier. |
| db_instance_endpoint | The connection endpoint. |
| db_instance_arn | The ARN of the RDS instance. |
| kms_key_id | The ID of the KMS key. |
| kms_key_arn | The ARN of the KMS key. |
