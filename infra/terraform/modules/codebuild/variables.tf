variable "name_prefix" {
  description = "Resource name prefix (e.g. fincorp-prod)."
  type        = string
}

variable "region" {
  description = "Region the build runs in (ECR + CodeArtifact live here)."
  type        = string
}

variable "account_id" {
  description = "AWS account id (for ECR registry + ARN scoping)."
  type        = string
}

# --- Per-tier build definitions -------------------------------------------
# One CodeBuild project per tier. Each entry wires a tier to its ECR repo,
# its CodeArtifact dependency repo, its app dir, and its buildspec file.
variable "tiers" {
  description = "Map of tier name -> build config (ecr_repo_name, ecr_repo_arn, ca_repo, app_dir, buildspec_file, manager: npm|pip)."
  type = map(object({
    ecr_repo_name  = string
    ecr_repo_arn   = string
    ca_repo        = string
    app_dir        = string
    buildspec_file = string
  }))
}

# --- CodeArtifact (shared across tiers) -----------------------------------
variable "codeartifact_domain" {
  description = "CodeArtifact domain name."
  type        = string
}

variable "codeartifact_domain_owner" {
  description = "CodeArtifact domain owner account id."
  type        = string
}

variable "codeartifact_domain_arn" {
  description = "CodeArtifact domain ARN (for sts:GetServiceBearerToken scoping)."
  type        = string
}

variable "codeartifact_repository_arns" {
  description = "List of CodeArtifact repository ARNs the build may read from."
  type        = list(string)
}

variable "artifact_bucket_arn" {
  description = "ARN of the CodePipeline artifact S3 bucket (build needs object read/write)."
  type        = string
}

variable "compute_type" {
  description = "CodeBuild compute size."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "CodeBuild managed image (must support Docker via privileged mode)."
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for build logs."
  type        = number
  default     = 30
}
