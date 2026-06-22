variable "primary_region" {
  description = "Primary AWS region (pipeline, ECR, CodeArtifact, primary RDS)."
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "Disaster-recovery region (cross-region backup copy + restore)."
  type        = string
  default     = "us-west-2"
}

variable "project" {
  description = "Project name; used as a prefix and tag."
  type        = string
  default     = "fincorp"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}
