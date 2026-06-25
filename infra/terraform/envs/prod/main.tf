locals {
  name_prefix = "${var.project}-${var.environment}" # fincorp-prod
}

data "aws_caller_identity" "current" {}

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
# One repo per app tier (fincorp-frontend, fincorp-backend) — each tier builds a
# distinct image and pulls its deps through its own CodeArtifact upstream.
module "ecr" {
  source = "../../modules/ecr"

  project      = var.project
  repositories = ["frontend", "backend"]
}

# CodeArtifact: the single controlled npm + pip proxy the build pulls through.
module "codeartifact" {
  source = "../../modules/codeartifact"

  project = var.project
}

# ===========================================================================
# Objective 1 — secure artifact pipeline (Phase 2)
# ===========================================================================

# Shared pipeline artifact bucket (used by both CodeBuild and CodePipeline).
# Created in the root to break the codebuild <-> codepipeline dependency cycle.
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = "${local.name_prefix}-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # lab: teardown removes versioned artifacts cleanly
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket                  = aws_s3_bucket.pipeline_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# One CodeBuild project per tier: CodeArtifact deps -> image -> push -> scan gate.
module "codebuild" {
  source = "../../modules/codebuild"

  name_prefix = local.name_prefix
  region      = var.primary_region
  account_id  = data.aws_caller_identity.current.account_id

  tiers = {
    frontend = {
      ecr_repo_name  = "${var.project}-frontend"
      ecr_repo_arn   = module.ecr.repository_arns_by_name["${var.project}-frontend"]
      ca_repo        = module.codeartifact.npm_repository_name
      app_dir        = "apps/frontend"
      buildspec_file = "frontend.yml"
    }
    backend = {
      ecr_repo_name  = "${var.project}-backend"
      ecr_repo_arn   = module.ecr.repository_arns_by_name["${var.project}-backend"]
      ca_repo        = module.codeartifact.pip_repository_name
      app_dir        = "apps/backend"
      buildspec_file = "backend.yml"
    }
  }

  codeartifact_domain          = module.codeartifact.domain_name
  codeartifact_domain_owner    = module.codeartifact.domain_owner
  codeartifact_domain_arn      = module.codeartifact.domain_arn
  codeartifact_repository_arns = values(module.codeartifact.repository_arns)
  artifact_bucket_arn          = aws_s3_bucket.pipeline_artifacts.arn
}

# Source (GitHub via CodeStar connection) -> Build (both tiers in parallel).
module "codepipeline" {
  source = "../../modules/codepipeline"

  name_prefix          = local.name_prefix
  github_owner         = var.github_owner
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  build_projects       = module.codebuild.project_names
  build_project_arns   = module.codebuild.project_arns
  artifact_bucket_arn  = aws_s3_bucket.pipeline_artifacts.arn
  artifact_bucket_name = aws_s3_bucket.pipeline_artifacts.bucket
}

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
