locals {
  name_prefix = "${var.project}-${var.environment}" # fincorp-prod
}

# ===========================================================================
# Foundation (Phase 1) — primary region (default provider = us-east-1)
# ===========================================================================

# Lean, RDS-only VPC: private data subnets across 2 AZs + RDS SG + DB subnet
# group. No IGW/NAT (RDS is private with no egress need) — see module header.
module "network" {
  source = "../../modules/network"

  name_prefix               = local.name_prefix
  vpc_cidr                  = var.vpc_cidr
  azs                       = var.azs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
}

# Immutable, scanned image store. IMMUTABLE tags + scan-on-push (AGENTS.md §2).
module "ecr" {
  source = "../../modules/ecr"

  project = var.project
}

# CodeArtifact: the single controlled npm + pip proxy the build pulls through.
module "codeartifact" {
  source = "../../modules/codeartifact"

  project = var.project
}

# ===========================================================================
# Objective 1 — secure artifact pipeline (Phases 2-3)
# ===========================================================================
# module "codebuild"    { source = "../../modules/codebuild" }    # build + scan gate
# module "codepipeline" { source = "../../modules/codepipeline" } # GitHub (CodeStar) -> build

# ===========================================================================
# Objective 2 — cross-region disaster recovery (Phases 4-5)
# ===========================================================================
# module "secrets" { source = "../../modules/secrets" }           # RDS master password
#
# module "rds" {
#   source = "../../modules/rds"
#   # primary RDS in us-east-1 (default provider), wired to module.network
# }
#
# module "backup" {
#   source = "../../modules/backup"
#   providers = {
#     aws      = aws        # us-east-1 vault + plan
#     aws.usw2 = aws.usw2   # us-west-2 destination vault (cross-region copy)
#   }
# }
