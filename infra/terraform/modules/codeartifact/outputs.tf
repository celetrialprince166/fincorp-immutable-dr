output "domain_name" {
  description = "CodeArtifact domain name (used by `aws codeartifact login` / get-authorization-token)."
  value       = aws_codeartifact_domain.this.domain
}

output "domain_owner" {
  description = "AWS account ID that owns the domain (required as --domain-owner in CodeArtifact CLI calls)."
  value       = aws_codeartifact_domain.this.owner
}

output "domain_arn" {
  description = "ARN of the CodeArtifact domain (for IAM scoping)."
  value       = aws_codeartifact_domain.this.arn
}

output "npm_repository_name" {
  description = "Name of the npm repo the build pulls from (upstreams to npm-store)."
  value       = aws_codeartifact_repository.npm.repository
}

output "pip_repository_name" {
  description = "Name of the pip/python repo the build pulls from (upstreams to pypi-store)."
  value       = aws_codeartifact_repository.pip.repository
}

output "repository_arns" {
  description = "Map of repo name -> ARN for all four repos (for least-privilege IAM scoping)."
  value = {
    (aws_codeartifact_repository.npm_store.repository)  = aws_codeartifact_repository.npm_store.arn
    (aws_codeartifact_repository.pypi_store.repository) = aws_codeartifact_repository.pypi_store.arn
    (aws_codeartifact_repository.npm.repository)        = aws_codeartifact_repository.npm.arn
    (aws_codeartifact_repository.pip.repository)        = aws_codeartifact_repository.pip.arn
  }
}
