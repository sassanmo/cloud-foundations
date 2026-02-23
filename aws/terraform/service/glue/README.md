# AWS Glue Terraform Module

This module creates AWS Glue resources including databases, crawlers, jobs, and triggers for ETL workloads.

## Features

- Glue Data Catalog database
- Crawlers for S3 and JDBC sources
- ETL jobs with Python/Scala support
- Job triggers (scheduled, on-demand, conditional)
- Schema change policies
- Worker type and capacity configuration

## Usage

### Basic Glue ETL Pipeline

```hcl
module "glue" {
  source = "../../service/glue"

  project     = "myapp"
  environment = "prod"
  
  description = "Analytics ETL pipeline"
  
  crawlers = {
    raw_data = {
      role_arn = module.glue_role.role_arn
      s3_targets = [
        {
          path = "s3://myapp-prod-raw-data/"
        }
      ]
      schedule = "cron(0 2 * * ? *)"
    }
  }
  
  jobs = {
    transform_data = {
      role_arn        = module.glue_role.role_arn
      script_location = "s3://myapp-prod-scripts/transform.py"
      glue_version    = "4.0"
      worker_type     = "G.1X"
      number_of_workers = 2
      default_arguments = {
        "--job-language"        = "python"
        "--enable-metrics"      = "true"
        "--enable-spark-ui"     = "true"
        "--spark-event-logs-path" = "s3://myapp-prod-logs/spark/"
      }
    }
  }
  
  triggers = {
    daily_transform = {
      type     = "SCHEDULED"
      schedule = "cron(0 3 * * ? *)"
      job_key  = "transform_data"
    }
  }
  
  tags = {
    Team = "analytics"
  }
}
```

### Glue with Conditional Triggers

```hcl
module "glue" {
  source = "../../service/glue"

  project     = "myapp"
  environment = "prod"
  
  crawlers = {
    source_data = {
      role_arn = module.glue_role.role_arn
      s3_targets = [
        {
          path = "s3://myapp-prod-source/"
        }
      ]
    }
  }
  
  jobs = {
    process_data = {
      role_arn        = module.glue_role.role_arn
      script_location = "s3://myapp-scripts/process.py"
      worker_type     = "G.2X"
      number_of_workers = 5
    }
  }
  
  triggers = {
    on_crawler_success = {
      type    = "CONDITIONAL"
      job_key = "process_data"
      predicate = {
        logical = "ANY"
        conditions = [
          {
            crawler_name = "source_data"
            crawl_state  = "SUCCEEDED"
          }
        ]
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
| crawlers | Map of crawlers | `map(object)` | `{}` | no |
| jobs | Map of ETL jobs | `map(object)` | `{}` | no |
| triggers | Map of triggers | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| database_name | Name of the Glue database |
| crawler_names | Map of crawler names |
| job_names | Map of job names |
| trigger_names | Map of trigger names |

## Worker Types

- `Standard` - 4 vCPU, 16 GB memory
- `G.1X` - 1 DPU (4 vCPU, 16 GB)
- `G.2X` - 2 DPU (8 vCPU, 32 GB)
- `G.025X` - 0.25 DPU (2 vCPU, 4 GB)

## Trigger Types

- `SCHEDULED` - Cron-based schedule
- `ON_DEMAND` - Manual trigger
- `CONDITIONAL` - Based on job/crawler state

## Notes

- Database naming: `{project}-{environment}-glue`
- Crawlers discover schema from S3/JDBC
- Jobs can be Python or Scala
- Glue 4.0 is the latest version (supports Spark 3.3)
- Use G.1X or G.2X workers for production
- Triggers can chain multiple jobs
resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = var.assume_role_policy

  description           = var.description
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary

  tags = merge(var.tags, { Name = local.role_name })
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = local.role_name
  role = aws_iam_role.this.name

  tags = merge(var.tags, { Name = local.role_name })
}

