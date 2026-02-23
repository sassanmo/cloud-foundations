# Backend configuration for storing Terraform state in S3
#
# Before using this backend, you must first create the state backend infrastructure
# using the bootstrap configuration at: ../../bootstrap/terraform-state-backend/
#
# Uncomment and configure the backend block below after creating the bootstrap resources:

# terraform {
#   backend "s3" {
#     bucket         = "469240347599-terraform-states-prod"  # From bootstrap output: s3_bucket_name
#     key            = "ecr/terraform.tfstate"               # Unique key for this project
#     region         = "eu-west-1"                            # Same region as bootstrap
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock-prod"           # From bootstrap output: dynamodb_table_name
#   }
# }

# Alternative: Use partial configuration with backend-config file
# Create a backend-config.hcl file and run: terraform init -backend-config=backend-config.hcl
