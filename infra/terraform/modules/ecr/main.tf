# Immutable, scanned image store. IMMUTABLE tags are the non-negotiable prime
# directive (AGENTS.md §2): an image tagged by git short SHA can never be
# overwritten, so every artifact is traceable and auditable. scan_on_push runs
# the ECR/Inspector vulnerability scan automatically; the CodeBuild gate later
# fails the build on any HIGH/CRITICAL finding.
resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = "${var.project}-${each.value}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = { Name = "${var.project}-${each.value}" }
}

# Retain the most recent N images; expire older to control storage cost.
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = { type = "expire" }
      }
    ]
  })
}
