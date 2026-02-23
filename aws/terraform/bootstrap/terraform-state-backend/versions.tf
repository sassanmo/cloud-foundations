terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0.0"
      configuration_aliases = [aws.replication]
    }
  }
}

provider "aws" {
  region = var.region
}

# Provider for replication region (used when enable_replication = true)
provider "aws" {
  alias  = "replication"
  region = var.replication_region != "" ? var.replication_region : var.region
}
