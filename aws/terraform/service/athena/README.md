# AWS Athena Terraform Module

This module creates AWS Athena workgroups, databases, and named queries for SQL analytics on S3 data.

## Features

- Athena workgroup with query result configuration
- Multiple database creation
- Query result encryption with KMS
- Named queries for reusable SQL
- CloudWatch metrics integration
- Query cost controls with bytes scanned limit

## Usage

### Basic Athena Setup

```hcl
module "athena" {
  source = "../../service/athena"

  project     = "myapp"
  environment = "prod"
  
  output_location = "s3://myapp-prod-athena-results/"
  
  encryption_configuration = {
    encryption_option = "SSE_KMS"
    kms_key_arn       = module.kms.key_arn
  }
  
  databases = {
    analytics = {
      bucket  = "myapp-prod-data"
      comment = "Analytics database"
    }
  }
  
  named_queries = {
    daily_users = {
      database    = "analytics"
      description = "Count daily active users"
      query       = <<-SQL
        SELECT 
          DATE(timestamp) as date,
          COUNT(DISTINCT user_id) as daily_users
        FROM events
        WHERE DATE(timestamp) = CURRENT_DATE
        GROUP BY DATE(timestamp)
      SQL
    }
  }
  
  tags = {
    Team = "analytics"
  }
}
```

### Athena with Cost Controls

```hcl
module "athena" {
  source = "../../service/athena"

  project     = "myapp"
  environment = "prod"
  
  output_location = "s3://myapp-prod-athena-results/"
  
  # Limit to 100GB per query
  bytes_scanned_cutoff_per_query = 107374182400
  
  enforce_workgroup_configuration = true
  
  encryption_configuration = {
    encryption_option = "SSE_S3"
  }
  
  databases = {
    logs = {
      bucket        = "myapp-prod-logs"
      force_destroy = false
      encryption_configuration = {
        encryption_option = "SSE_KMS"
        kms_key           = module.kms.key_id
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
| output_location | S3 location for results | `string` | n/a | yes |
| databases | Map of databases | `map(object)` | `{}` | no |
| named_queries | Map of named queries | `map(object)` | `{}` | no |
| encryption_configuration | Encryption config | `object` | `null` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| workgroup_name | Name of the workgroup |
| workgroup_arn | ARN of the workgroup |
| database_names | Map of database names |
| named_query_ids | Map of named query IDs |

## Encryption Options

- `SSE_S3` - S3 server-side encryption
- `SSE_KMS` - KMS encryption (requires `kms_key_arn`)
- `CSE_KMS` - Client-side KMS encryption

## Notes

- Query results are stored in the specified S3 location
- Use workgroups to separate teams and control costs
- Named queries can be shared across teams
- Athena charges based on data scanned ($5 per TB)
- Use columnar formats (Parquet, ORC) to reduce costs
- Partition data by date for faster queries

