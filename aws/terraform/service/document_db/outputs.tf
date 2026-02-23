output "cluster_id" {
  description = "The DocumentDB cluster identifier."
  value       = aws_docdb_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the DocumentDB cluster."
  value       = aws_docdb_cluster.this.arn
}

output "cluster_endpoint" {
  description = "The cluster endpoint for write operations."
  value       = aws_docdb_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint for read operations."
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "cluster_port" {
  description = "The port on which the DocumentDB cluster accepts connections."
  value       = aws_docdb_cluster.this.port
}

output "instance_ids" {
  description = "List of DocumentDB instance identifiers."
  value       = aws_docdb_cluster_instance.this[*].id
}
