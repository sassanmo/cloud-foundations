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

