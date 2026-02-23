# AWS ElastiCache Terraform Module

This module creates an Amazon ElastiCache replication group for Valkey, Redis, or Memcached.

## Features

- Valkey (default), Redis, or Memcached engine support
- Multi-AZ with automatic failover
- Encryption at rest and in transit
- Valkey/Redis AUTH support
- Automated backups
- CloudWatch Logs integration
- SNS notifications

## Usage

```hcl
module "valkey" {
  source = "../../service/elasticache"

  project     = "myapp"
  environment = "prod"
  
  engine         = "valkey"
  engine_version = "7.2"
  node_type      = "cache.r6g.large"
  num_cache_clusters = 2
  
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.valkey.id]
  
  auth_token_enabled = true
  auth_token         = var.valkey_password
  
  kms_key_id = module.kms.key_id
  
  tags = {
    Team = "platform"
  }
}
```

### Using Redis (Deprecated)

```hcl
module "redis" {
  source = "../../service/elasticache"

  project     = "myapp"
  environment = "prod"
  
  engine         = "redis"
  engine_version = "7.0"
  node_type      = "cache.r6g.large"
  num_cache_clusters = 2
  
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.redis.id]
  
  auth_token_enabled = true
  auth_token         = var.redis_password
  
  kms_key_id = module.kms.key_id
}
```

## Outputs

| Name | Description |
|------|-------------|
| primary_endpoint_address | Primary endpoint address |
| reader_endpoint_address | Reader endpoint address |
| port | Port number |

## Notes

- **Valkey** is now the default engine (AWS's open-source Redis alternative)
- Redis OSS is deprecated by AWS but still supported in this module
- Valkey is fully compatible with Redis APIs and protocols
- Default naming: `{project}-{environment}-valkey`
