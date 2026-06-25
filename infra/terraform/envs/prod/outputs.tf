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

# ---------------------------------------------------------------------------
# Phase 4 outputs — disaster-recovery foundation (RDS + AWS Backup).
# ---------------------------------------------------------------------------

output "rds_instance_id" {
  description = "Primary RDS instance identifier (us-east-1)."
  value       = module.rds.db_instance_id
}

output "rds_endpoint" {
  description = "Primary RDS endpoint (host:port)."
  value       = module.rds.endpoint
}

output "rds_arn" {
  description = "Primary RDS instance ARN (AWS Backup selection target)."
  value       = module.rds.arn
}

output "rds_master_secret_arn" {
  description = "ARN of the RDS-managed master-user secret (Secrets Manager). ARN only — never the value."
  value       = module.rds.master_user_secret_arn
}

output "backup_vault_use1_arn" {
  description = "us-east-1 source backup vault ARN."
  value       = module.backup.primary_vault_arn
}

output "backup_vault_usw2_arn" {
  description = "us-west-2 destination (cross-region copy) backup vault ARN."
  value       = module.backup.dr_vault_arn
}

output "backup_vault_use1_name" {
  description = "us-east-1 source backup vault name."
  value       = module.backup.primary_vault_name
}

output "backup_vault_usw2_name" {
  description = "us-west-2 destination backup vault name."
  value       = module.backup.dr_vault_name
}

output "backup_plan_id" {
  description = "AWS Backup plan id (daily rule + cross-region copy_action)."
  value       = module.backup.plan_id
}

output "backup_role_arn" {
  description = "AWS Backup service role ARN (used for on-demand jobs too)."
  value       = module.backup.backup_role_arn
}
