output "table_id" {
  description = "The name of the table."
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "The ARN of the table."
  value       = aws_dynamodb_table.this.arn
}

output "table_name" {
  description = "The name of the table."
  value       = aws_dynamodb_table.this.name
}

output "table_stream_arn" {
  description = "The ARN of the Table Stream (only if enabled)."
  value       = aws_dynamodb_table.this.stream_arn
}
