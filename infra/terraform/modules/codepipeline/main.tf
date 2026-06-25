# ===========================================================================
# CodePipeline — Source (GitHub via CodeStar/CodeConnections) -> Build.
# The Build stage runs BOTH tiers as parallel actions (runOrder = 1), each in
# its own CodeBuild project (which carries the CodeArtifact deps + scan gate).
#
# The CodeStar connection is created in PENDING state by Terraform; a human must
# authorize it once in the console (OAuth handshake). Until then the pipeline
# exists but Source cannot pull. This is by design — we do not block the apply.
# ===========================================================================

# --- GitHub connection (PENDING until a human authorizes in the console) ---
resource "aws_codestarconnections_connection" "github" {
  name          = substr("${var.name_prefix}-gh", 0, 32)
  provider_type = "GitHub"
}

# --- Pipeline role ---------------------------------------------------------
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${var.name_prefix}-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "pipeline" {
  # S3 artifact bucket only.
  statement {
    sid    = "S3Artifacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
    ]
    resources = [var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*"]
  }

  # Start only this project's CodeBuild builds.
  statement {
    sid       = "StartBuild"
    effect    = "Allow"
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = [for a in var.build_project_arns : a]
  }

  # Use only this GitHub connection.
  statement {
    sid       = "UseConnection"
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection", "codeconnections:UseConnection"]
    resources = [aws_codestarconnections_connection.github.arn]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  name   = "${var.name_prefix}-codepipeline"
  role   = aws_iam_role.pipeline.id
  policy = data.aws_iam_policy_document.pipeline.json
}

# --- Pipeline --------------------------------------------------------------
resource "aws_codepipeline" "this" {
  name     = "${var.name_prefix}-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    type     = "S3"
    location = var.artifact_bucket_name
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"
    # Both tiers build in parallel (same runOrder) — independent images.
    dynamic "action" {
      for_each = var.build_projects
      content {
        name             = title(action.key)
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        run_order        = 1
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_${action.key}"]
        configuration = {
          ProjectName = action.value
        }
      }
    }
  }
}
