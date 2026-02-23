resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0

  control_finding_generator = var.control_finding_generator
  auto_enable_controls      = var.auto_enable_controls
}

# CIS AWS Foundations Benchmark
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_security_hub && var.enable_cis_standard ? 1 : 0

  standards_arn = "arn:${var.partition}:securityhub:${var.region}::standards/cis-aws-foundations-benchmark/v/1.4.0"

  depends_on = [aws_securityhub_account.this]
}

# AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_security_hub && var.enable_aws_foundational_standard ? 1 : 0

  standards_arn = "arn:${var.partition}:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]
}

# PCI DSS
resource "aws_securityhub_standards_subscription" "pci_dss" {
  count = var.enable_security_hub && var.enable_pci_dss_standard ? 1 : 0

  standards_arn = "arn:${var.partition}:securityhub:${var.region}::standards/pci-dss/v/3.2.1"

  depends_on = [aws_securityhub_account.this]
}

# NIST 800-53
resource "aws_securityhub_standards_subscription" "nist" {
  count = var.enable_security_hub && var.enable_nist_standard ? 1 : 0

  standards_arn = "arn:${var.partition}:securityhub:${var.region}::standards/nist-800-53/v/5.0.0"

  depends_on = [aws_securityhub_account.this]
}

# Custom Action Target
resource "aws_securityhub_action_target" "this" {
  count = var.enable_security_hub && var.action_target_name != null ? 1 : 0

  name        = local.action_target_name
  identifier  = var.action_target_identifier
  description = var.action_target_description

  depends_on = [aws_securityhub_account.this]
}

# Member Accounts
resource "aws_securityhub_member" "this" {
  for_each = var.enable_security_hub ? toset(var.member_accounts) : []

  account_id = each.value
  invite     = true

  depends_on = [aws_securityhub_account.this]
}

