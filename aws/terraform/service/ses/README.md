# AWS SES Terraform Module

This module creates Amazon SES (Simple Email Service) domain and email identities for sending emails.

## Features

- Domain identity verification
- DKIM configuration
- Custom MAIL FROM domain
- Email address verification
- Configuration sets
- Event destinations (CloudWatch, SNS)
- Reputation metrics

## Usage

```hcl
module "ses" {
  source = "../../service/ses"

  project     = "myapp"
  environment = "prod"
  
  domain           = "myapp.com"
  mail_from_domain = "mail.myapp.com"
  
  email_identities = [
    "noreply@myapp.com",
    "support@myapp.com"
  ]
  
  event_destinations = {
    cloudwatch = {
      matching_types = ["send", "reject", "bounce", "complaint"]
      cloudwatch_destination = {
        default_value  = "default"
        dimension_name = "ses:configuration-set"
        value_source   = "messageTag"
      }
    }
  }
  
  tags = {
    Team = "platform"
  }
}
```

## DNS Records Required

After creation, add these DNS records:

1. **Domain Verification**: TXT record with verification token
2. **DKIM**: 3 CNAME records with DKIM tokens
3. **MAIL FROM**: MX and TXT records for custom MAIL FROM domain

## Outputs

| Name | Description |
|------|-------------|
| domain_identity_verification_token | Domain verification token |
| dkim_tokens | DKIM tokens for DNS |
| configuration_set_name | Configuration set name |
resource "aws_efs_file_system" "this" {
  creation_token = local.file_system_name
  encrypted      = true
  kms_key_id     = var.kms_key_id

  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy_transition_to_ia != null ? [1] : []
    content {
      transition_to_ia = var.lifecycle_policy_transition_to_ia
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy_transition_to_primary_storage_class != null ? [1] : []
    content {
      transition_to_primary_storage_class = var.lifecycle_policy_transition_to_primary_storage_class
    }
  }

  tags = merge(var.tags, { Name = local.file_system_name })
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}

resource "aws_efs_backup_policy" "this" {
  count = var.enable_backup_policy ? 1 : 0

  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_file_system_policy" "this" {
  count = var.file_system_policy != null ? 1 : 0

  file_system_id = aws_efs_file_system.this.id
  policy         = var.file_system_policy
}

resource "aws_efs_access_point" "this" {
  for_each = var.access_points

  file_system_id = aws_efs_file_system.this.id

  posix_user {
    gid = each.value.posix_user.gid
    uid = each.value.posix_user.uid
    secondary_gids = each.value.posix_user.secondary_gids
  }

  root_directory {
    path = each.value.root_directory.path

    creation_info {
      owner_gid   = each.value.root_directory.creation_info.owner_gid
      owner_uid   = each.value.root_directory.creation_info.owner_uid
      permissions = each.value.root_directory.creation_info.permissions
    }
  }

  tags = merge(var.tags, { Name = "${local.file_system_name}-${each.key}" })
}

