output "repository_urls" {
  description = "Map of short name -> repository URL."
  value       = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}

output "repository_arns" {
  description = "List of repository ARNs (for IAM scoping)."
  value       = [for r in aws_ecr_repository.this : r.arn]
}

output "repository_arns_by_name" {
  description = "Map of full repository name (fincorp-<tier>) -> ARN, for per-repo IAM scoping."
  value       = { for r in aws_ecr_repository.this : r.name => r.arn }
}
