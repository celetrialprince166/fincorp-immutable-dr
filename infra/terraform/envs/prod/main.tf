locals {
  name_prefix = "${var.project}-${var.environment}" # fincorp-prod
}

# ===========================================================================
# Foundation (Phase 1) — primary region (default provider = us-east-1)
# ===========================================================================
# module "network" {
#   source = "../../modules/network"
#   ...
# }
#
# module "ecr" {
#   source = "../../modules/ecr"
#   # Phase 1: set image_tag_mutability = "IMMUTABLE" (scan_on_push already true).
# }
#
# module "codeartifact" {
#   source = "../../modules/codeartifact"   # npm + pip upstream proxies
# }

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
#   # primary RDS in us-east-1 (default provider)
# }
#
# module "backup" {
#   source = "../../modules/backup"
#   providers = {
#     aws      = aws        # us-east-1 vault + plan
#     aws.usw2 = aws.usw2   # us-west-2 destination vault (cross-region copy)
#   }
# }
