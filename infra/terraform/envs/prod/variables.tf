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
