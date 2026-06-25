output "project_names" {
  description = "Map of tier -> CodeBuild project name."
  value       = { for k, p in aws_codebuild_project.this : k => p.name }
}

output "project_arns" {
  description = "Map of tier -> CodeBuild project ARN (for pipeline + IAM)."
  value       = { for k, p in aws_codebuild_project.this : k => p.arn }
}

output "role_arn" {
  description = "CodeBuild service role ARN."
  value       = aws_iam_role.build.arn
}
