# API Gateway Module

This module creates a secure AWS API Gateway REST API following AWS best practices.

## Features

- CloudWatch logging enabled by default
- X-Ray tracing enabled by default
- CloudWatch metrics enabled by default
- Throttling configured by default
- Response compression support
- 90-day log retention

## Usage

```hcl
module "api_gateway" {
  source = "../../service/api_gateway"

  name          = "my-api"
  description   = "My REST API"
  stage_name    = "v1"
  endpoint_type = "REGIONAL"

  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn

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
| name | Name of the API Gateway REST API. | `string` | n/a | yes |
| description | Description of the REST API. | `string` | `""` | no |
| endpoint_type | Endpoint type (REGIONAL, EDGE, or PRIVATE). | `string` | `"REGIONAL"` | no |
| stage_name | Name of the deployment stage. | `string` | `"v1"` | no |
| logging_level | Logging level (OFF, ERROR, INFO). | `string` | `"ERROR"` | no |
| metrics_enabled | Enable CloudWatch metrics. | `bool` | `true` | no |
| xray_tracing_enabled | Enable X-Ray tracing. | `bool` | `true` | no |
| throttling_burst_limit | Throttling burst limit. | `number` | `500` | no |
| throttling_rate_limit | Throttling rate limit. | `number` | `1000` | no |
| cloudwatch_role_arn | ARN of IAM role for CloudWatch logging. | `string` | `""` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_id | The ID of the REST API. |
| api_arn | The ARN of the REST API. |
| root_resource_id | The resource ID of the REST API root. |
| stage_invoke_url | The URL to invoke the API. |
| stage_arn | The ARN of the API Gateway stage. |
| cloudwatch_log_group_arn | The ARN of the CloudWatch log group. |
