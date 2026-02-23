# AWS EKS Terraform Module

This module creates an Amazon EKS (Elastic Kubernetes Service) cluster with control plane logging and optional addons.

## Features

- EKS cluster with configurable Kubernetes version
- Control plane logging to CloudWatch
- Secrets encryption with KMS
- VPC and endpoint configuration
- EKS addons (VPC CNI, CoreDNS, kube-proxy, EBS CSI driver)
- Automatic IAM role creation for cluster

## Usage

### Basic EKS Cluster

```hcl
module "eks" {
  source = "../../service/eks"

  project     = "myapp"
  environment = "prod"
  
  kubernetes_version = "1.28"
  subnet_ids         = module.vpc.private_subnet_ids
  
  tags = {
    Team = "platform"
  }
}
```

### EKS with Addons

```hcl
module "eks" {
  source = "../../service/eks"

  project     = "myapp"
  environment = "prod"
  
  kubernetes_version = "1.28"
  subnet_ids         = concat(
    module.vpc.private_subnet_ids,
    module.vpc.public_subnet_ids
  )
  
  addons = {
    vpc-cni = {
      addon_version = "v1.15.0-eksbuild.2"
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.2"
    }
    kube-proxy = {
      addon_version = "v1.28.1-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      addon_version = "v1.24.0-eksbuild.1"
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
| subnet_ids | Subnet IDs for cluster | `list(string)` | n/a | yes |
| kubernetes_version | Kubernetes version | `string` | `"1.28"` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | EKS cluster API endpoint |
| cluster_name | Name of the EKS cluster |
| cluster_oidc_issuer_url | OIDC issuer URL |

## Notes

- Cluster naming: `{project}-{environment}-eks`
- Requires node groups (create separate module for node groups)
- Use OIDC provider for IRSA (IAM Roles for Service Accounts)
resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = var.create_cluster_role ? aws_iam_role.cluster[0].arn : var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.cluster_security_group_ids
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  dynamic "encryption_config" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      provider {
        key_arn = var.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  tags = merge(var.tags, { Name = local.cluster_name })

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.vpc_resource_controller,
    aws_cloudwatch_log_group.cluster
  ]
}

resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = each.key
  addon_version            = each.value.addon_version
  resolve_conflicts        = each.value.resolve_conflicts
  service_account_role_arn = each.value.service_account_role_arn

  tags = merge(var.tags, { Name = "${local.cluster_name}-${each.key}" })
}

resource "aws_iam_role" "cluster" {
  count = var.create_cluster_role ? 1 : 0

  name               = local.cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role[0].json

  tags = merge(var.tags, { Name = local.cluster_role_name })
}

data "aws_iam_policy_document" "cluster_assume_role" {
  count = var.create_cluster_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  count = var.create_cluster_role ? 1 : 0

  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "vpc_resource_controller" {
  count = var.create_cluster_role ? 1 : 0

  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_cloudwatch_log_group" "cluster" {
  count = length(var.enabled_cluster_log_types) > 0 ? 1 : 0

  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(var.tags, { Name = "/aws/eks/${local.cluster_name}/cluster" })
}

