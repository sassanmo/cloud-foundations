output "security_hub_id" {
  description = "Security Hub account ID"
  value       = var.enable_security_hub ? aws_securityhub_account.this[0].id : null
}

output "security_hub_arn" {
  description = "Security Hub account ARN"
  value       = var.enable_security_hub ? aws_securityhub_account.this[0].arn : null
}

output "cis_subscription_arn" {
  description = "ARN of the CIS standard subscription"
  value       = var.enable_security_hub && var.enable_cis_standard ? aws_securityhub_standards_subscription.cis[0].standards_arn : null
}

output "aws_foundational_subscription_arn" {
  description = "ARN of the AWS Foundational standard subscription"
  value       = var.enable_security_hub && var.enable_aws_foundational_standard ? aws_securityhub_standards_subscription.aws_foundational[0].standards_arn : null
}

output "pci_dss_subscription_arn" {
  description = "ARN of the PCI DSS standard subscription"
  value       = var.enable_security_hub && var.enable_pci_dss_standard ? aws_securityhub_standards_subscription.pci_dss[0].standards_arn : null
}

output "nist_subscription_arn" {
  description = "ARN of the NIST standard subscription"
  value       = var.enable_security_hub && var.enable_nist_standard ? aws_securityhub_standards_subscription.nist[0].standards_arn : null
}

output "action_target_arn" {
  description = "ARN of the custom action target"
  value       = var.enable_security_hub && var.action_target_name != null ? aws_securityhub_action_target.this[0].arn : null
}

