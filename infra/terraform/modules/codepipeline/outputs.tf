output "pipeline_name" {
  description = "CodePipeline name."
  value       = aws_codepipeline.this.name
}

output "connection_arn" {
  description = "CodeStar/CodeConnections GitHub connection ARN (PENDING until authorized)."
  value       = aws_codestarconnections_connection.github.arn
}

output "connection_status" {
  description = "Connection status — PENDING until a human authorizes it in the console."
  value       = aws_codestarconnections_connection.github.connection_status
}
