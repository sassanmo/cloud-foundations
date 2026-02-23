# AWS EFS Terraform Module

This module creates an Amazon EFS (Elastic File System) with mount targets and access points.

## Features

- Encrypted EFS file system with KMS
- Mount targets across multiple subnets
- Lifecycle policies for cost optimization
- Access points for application-specific access
- Automatic backups with AWS Backup
- Custom file system policies

## Usage

```hcl
module "efs" {
  source = "../../service/efs"

  project     = "myapp"
  environment = "prod"
  
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.efs.id]
  
  kms_key_id = module.kms.key_id
  
  access_points = {
    app = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/app"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| file_system_id | EFS file system ID |
| file_system_dns_name | DNS name for mounting |
| access_point_ids | Map of access point IDs |

