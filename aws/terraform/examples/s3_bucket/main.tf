# Example: Simple S3 bucket with AES256 encryption
module "s3_bucket_simple" {
  source = "../../service/s3"

  bucket_name        = "my-simple-bucket-${random_id.suffix.hex}"
  versioning_enabled = true

  lifecycle_rules = [
    {
      id      = "expire-noncurrent-versions"
      enabled = true
      noncurrent_version_expiration_days = 90
    }
  ]

  tags = {
    Environment = "example"
    Module      = "s3"
  }
}

# Example: S3 bucket with KMS encryption (composite module)
module "s3_bucket_kms" {
  source = "../../composite/s3_with_kms"

  bucket_name    = "my-kms-bucket-${random_id.suffix.hex}"
  kms_alias_name = "alias/my-example-bucket-key"

  tags = {
    Environment = "example"
    Module      = "s3_with_kms"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
