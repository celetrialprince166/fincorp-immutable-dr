variable "name_prefix" {
  description = "Resource name prefix (e.g. fincorp-prod)."
  type        = string
}

variable "github_owner" {
  description = "GitHub org/user that owns the source repo."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (owner/repo without the owner)."
  type        = string
}

variable "github_branch" {
  description = "Branch the pipeline tracks."
  type        = string
  default     = "master"
}

variable "build_projects" {
  description = "Map of tier -> CodeBuild project name (each becomes a parallel Build action)."
  type        = map(string)
}

variable "build_project_arns" {
  description = "Map of tier -> CodeBuild project ARN (for least-privilege StartBuild)."
  type        = map(string)
}

variable "artifact_bucket_arn" {
  description = "ARN of the pipeline artifact S3 bucket (created in the root)."
  type        = string
}

variable "artifact_bucket_name" {
  description = "Name of the pipeline artifact S3 bucket."
  type        = string
}
