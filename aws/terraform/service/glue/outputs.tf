output "database_name" {
  description = "Name of the Glue database"
  value       = aws_glue_catalog_database.this.name
}

output "database_id" {
  description = "ID of the Glue database"
  value       = aws_glue_catalog_database.this.id
}

output "crawler_names" {
  description = "Map of crawler names"
  value       = { for k, v in aws_glue_crawler.this : k => v.name }
}

output "crawler_arns" {
  description = "Map of crawler ARNs"
  value       = { for k, v in aws_glue_crawler.this : k => v.arn }
}

output "job_names" {
  description = "Map of Glue job names"
  value       = { for k, v in aws_glue_job.this : k => v.name }
}

output "job_arns" {
  description = "Map of Glue job ARNs"
  value       = { for k, v in aws_glue_job.this : k => v.arn }
}

output "trigger_names" {
  description = "Map of trigger names"
  value       = { for k, v in aws_glue_trigger.this : k => v.name }
}

