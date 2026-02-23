output "workgroup_id" {
  description = "ID of the Athena workgroup"
  value       = aws_athena_workgroup.this.id
}

output "workgroup_arn" {
  description = "ARN of the Athena workgroup"
  value       = aws_athena_workgroup.this.arn
}

output "workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.this.name
}

output "database_names" {
  description = "Map of database names"
  value       = { for k, v in aws_athena_database.this : k => v.name }
}

output "named_query_ids" {
  description = "Map of named query IDs"
  value       = { for k, v in aws_athena_named_query.this : k => v.id }
}

