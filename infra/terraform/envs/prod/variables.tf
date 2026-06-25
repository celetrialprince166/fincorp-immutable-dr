variable "primary_region" {
  description = "Primary AWS region (pipeline, ECR, CodeArtifact, primary RDS)."
  type        = string
  default     = "us-east-1"
}

# DR region. NOTE: the AWS Organization SCP (p-339lo1q0) explicitly DENIES AWS
# Backup write actions (CreateBackupVault, etc.) in us-west-2 and all other US/CA
# regions; it permits only us-east-1 and EU regions (eu-west-1, eu-central-1).
# We therefore use eu-west-1 as the DR region — a genuinely distinct geography,
# which is an even stronger cross-region DR demonstration. The aws.usw2 provider
# alias name is retained for minimal churn but now points at this region.
variable "dr_region" {
  description = "Disaster-recovery region (cross-region backup copy + restore). Constrained to an SCP-allowed region."
  type        = string
  default     = "eu-west-1"
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

# --- Pipeline source (Phase 2) -------------------------------------------
variable "github_owner" {
  description = "GitHub org/user that owns the source repo."
  type        = string
  default     = "celetrialprince166"
}

variable "github_repo" {
  description = "GitHub repository name (without owner)."
  type        = string
  default     = "fincorp-immutable-dr"
}

variable "github_branch" {
  description = "Branch the pipeline tracks."
  type        = string
  default     = "master"
}

# --- Network (Phase 1) ---------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the primary-region VPC (hosts the RDS data subnets)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones for the private data subnets (>= 2, in the primary region)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks for the private data subnets, one per AZ in var.azs."
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}
