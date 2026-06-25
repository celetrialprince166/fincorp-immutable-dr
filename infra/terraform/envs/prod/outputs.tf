# ---------------------------------------------------------------------------
# Phase 1 outputs — foundation (network, ECR, CodeArtifact).
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "Primary-region VPC ID."
  value       = module.network.vpc_id
}

output "private_data_subnet_ids" {
  description = "Private data subnet IDs (RDS lives here)."
  value       = module.network.private_data_subnet_ids
}

output "rds_sg_id" {
  description = "RDS security group ID."
  value       = module.network.rds_sg_id
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name."
  value       = module.network.db_subnet_group_name
}

output "ecr_repository_urls" {
  description = "ECR repository URLs (immutable, scan-on-push)."
  value       = module.ecr.repository_urls
}

output "codeartifact_domain_name" {
  description = "CodeArtifact domain name."
  value       = module.codeartifact.domain_name
}

output "codeartifact_domain_owner" {
  description = "CodeArtifact domain owner (account id) for CLI --domain-owner."
  value       = module.codeartifact.domain_owner
}

output "codeartifact_npm_repository" {
  description = "npm repo the build pulls from (upstreams to npm-store -> public:npmjs)."
  value       = module.codeartifact.npm_repository_name
}

output "codeartifact_pip_repository" {
  description = "pip repo the build pulls from (upstreams to pypi-store -> public:pypi)."
  value       = module.codeartifact.pip_repository_name
}

# ---------------------------------------------------------------------------
# Phase 2 outputs — secure pipeline (CodeBuild, CodePipeline, CodeStar).
# ---------------------------------------------------------------------------

output "pipeline_name" {
  description = "CodePipeline name (Source -> Build both tiers)."
  value       = module.codepipeline.pipeline_name
}

output "codebuild_project_names" {
  description = "Map of tier -> CodeBuild project name."
  value       = module.codebuild.project_names
}

output "pipeline_artifact_bucket" {
  description = "S3 bucket holding pipeline artifacts."
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}

output "github_connection_arn" {
  description = "CodeStar GitHub connection ARN. PENDING until a human authorizes it in the console (Developer Tools -> Settings -> Connections)."
  value       = module.codepipeline.connection_arn
}

output "github_connection_status" {
  description = "Connection status. Must become AVAILABLE (manual OAuth authorize) before the pipeline can pull source."
  value       = module.codepipeline.connection_status
}
