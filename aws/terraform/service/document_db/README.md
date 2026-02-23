# DocumentDB Module

This module creates a secure AWS DocumentDB (MongoDB-compatible) cluster following AWS best practices.

## Features

- Storage encryption enabled by default
- Multi-instance cluster for high availability
- Automated backups with configurable retention
- Deletion protection enabled by default
- KMS encryption support

## Usage

```hcl
module "documentdb" {
  source = "../../service/document_db"

  cluster_identifier   = "my-docdb-cluster"
  master_username      = "dbadmin"
  master_password      = var.db_password
  db_subnet_group_name = aws_docdb_subnet_group.main.name

  vpc_security_group_ids = [aws_security_group.docdb.id]

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
| cluster_identifier | Identifier for the DocumentDB cluster. | `string` | n/a | yes |
| master_username | Master username. | `string` | n/a | yes |
| master_password | Master password. | `string` | n/a | yes |
| db_subnet_group_name | Name of the DB subnet group. | `string` | n/a | yes |
| engine_version | DocumentDB engine version. | `string` | `"5.0.0"` | no |
| instance_count | Number of instances. | `number` | `2` | no |
| instance_class | Instance class. | `string` | `"db.t3.medium"` | no |
| storage_encrypted | Enable storage encryption. | `bool` | `true` | no |
| kms_key_id | KMS key ARN for encryption. | `string` | `""` | no |
| backup_retention_period | Backup retention in days. | `number` | `7` | no |
| deletion_protection | Enable deletion protection. | `bool` | `true` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The DocumentDB cluster identifier. |
| cluster_arn | The ARN of the DocumentDB cluster. |
| cluster_endpoint | The cluster endpoint (write). |
| cluster_reader_endpoint | The cluster reader endpoint (read). |
| cluster_port | The cluster port. |
| instance_ids | List of instance identifiers. |
