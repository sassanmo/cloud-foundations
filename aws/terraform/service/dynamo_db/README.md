# DynamoDB Module

This module creates a secure AWS DynamoDB table following AWS best practices.

## Features

- Server-side encryption enabled by default (AWS managed or KMS)
- Point-in-time recovery enabled by default
- Pay-per-request billing by default
- Global secondary indexes support
- TTL support

## Usage

```hcl
module "dynamodb_table" {
  source = "../../service/dynamo_db"

  table_name = "my-table"
  hash_key   = "id"

  point_in_time_recovery = true

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
| table_name | Name of the DynamoDB table. | `string` | n/a | yes |
| hash_key | The partition key attribute name. | `string` | n/a | yes |
| hash_key_type | Attribute type for the hash key (S, N, B). | `string` | `"S"` | no |
| range_key | The sort key attribute name. | `string` | `""` | no |
| billing_mode | Billing mode (PROVISIONED or PAY_PER_REQUEST). | `string` | `"PAY_PER_REQUEST"` | no |
| enable_encryption | Enable server-side encryption. | `bool` | `true` | no |
| kms_key_arn | KMS key ARN for encryption. | `string` | `""` | no |
| point_in_time_recovery | Enable point-in-time recovery. | `bool` | `true` | no |
| ttl_attribute_name | TTL attribute name. Empty to disable TTL. | `string` | `""` | no |
| global_secondary_indexes | List of global secondary indexes. | `list(object)` | `[]` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| table_id | The name of the table. |
| table_arn | The ARN of the table. |
| table_name | The name of the table. |
| table_stream_arn | The ARN of the Table Stream. |
