output "domain_identity_arn" {
  description = "ARN of the SES domain identity"
  value       = aws_ses_domain_identity.this.arn
}

output "domain_identity_verification_token" {
  description = "Verification token for domain identity"
  value       = aws_ses_domain_identity.this.verification_token
}

output "dkim_tokens" {
  description = "DKIM tokens for DNS configuration"
  value       = aws_ses_domain_dkim.this.dkim_tokens
}

output "configuration_set_name" {
  description = "Name of the configuration set"
  value       = aws_ses_configuration_set.this.name
}

output "configuration_set_arn" {
  description = "ARN of the configuration set"
  value       = aws_ses_configuration_set.this.arn
}

output "email_identity_arns" {
  description = "Map of email identity ARNs"
  value       = { for k, v in aws_ses_email_identity.this : k => v.arn }
}

