# ===========================================================================
# CodeBuild — one project per app tier (frontend, backend).
# Each project: pulls deps through CodeArtifact, builds the tier's Docker image,
# pushes it SHA-tagged to the tier's IMMUTABLE ECR repo, then runs the scan gate
# (fail on HIGH/CRITICAL). securing-supply-chain controls #1-#4.
#
# IAM is least-privilege and split into two scopes:
#   * Shared statements (logs, CodeArtifact read, ECR auth-token, S3 artifacts).
#   * Per-tier ECR push/scan scoped to ONLY that tier's repo ARN.
# A single role grants both tiers' ECR repos (both repo ARNs are passed in),
# so the build role can never touch ECR repos outside this project.
# ===========================================================================

# --- CloudWatch Logs group per tier ---------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.tiers

  name              = "/codebuild/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_days
}

# --- Build role -----------------------------------------------------------
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "build" {
  name               = "${var.name_prefix}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "build" {
  # CloudWatch Logs — only this project's log groups.
  statement {
    sid       = "Logs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [for g in aws_cloudwatch_log_group.this : "${g.arn}:*"]
  }

  # ECR registry auth — GetAuthorizationToken is registry-wide by API design
  # (it returns a token for the whole registry and cannot be resource-scoped).
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # ECR push + scan-read — scoped to ONLY the two tier repos (no wildcard).
  statement {
    sid    = "EcrPushScan"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings",
    ]
    resources = [for t in var.tiers : t.ecr_repo_arn]
  }

  # CodeArtifact read — token for the domain, read on the repos, package reads.
  statement {
    sid       = "CodeArtifactToken"
    effect    = "Allow"
    actions   = ["codeartifact:GetAuthorizationToken"]
    resources = [var.codeartifact_domain_arn]
  }

  statement {
    sid    = "CodeArtifactRead"
    effect = "Allow"
    actions = [
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:ReadFromRepository",
    ]
    resources = var.codeartifact_repository_arns
  }

  # CodeArtifact uses an STS bearer token; this is the documented companion grant.
  statement {
    sid       = "StsBearer"
    effect    = "Allow"
    actions   = ["sts:GetServiceBearerToken"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "sts:AWSServiceName"
      values   = ["codeartifact.amazonaws.com"]
    }
  }

  # S3 artifact bucket — input/output artifacts for the pipeline.
  statement {
    sid    = "S3Artifacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = [var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "build" {
  name   = "${var.name_prefix}-codebuild"
  role   = aws_iam_role.build.id
  policy = data.aws_iam_policy_document.build.json
}

# --- CodeBuild projects ----------------------------------------------------
resource "aws_codebuild_project" "this" {
  for_each = var.tiers

  name         = "${var.name_prefix}-${each.key}"
  description  = "FinCorp secure build (${each.key}): CodeArtifact deps -> image -> push -> scan gate."
  service_role = aws_iam_role.build.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true # required to run the Docker daemon for docker build/push

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "ECR_REPO"
      value = each.value.ecr_repo_name
    }
    environment_variable {
      name  = "CA_DOMAIN"
      value = var.codeartifact_domain
    }
    environment_variable {
      name  = "CA_DOMAIN_OWNER"
      value = var.codeartifact_domain_owner
    }
    environment_variable {
      name  = each.key == "frontend" ? "CA_NPM_REPO" : "CA_PIP_REPO"
      value = each.value.ca_repo
    }
    environment_variable {
      name  = "APP_DIR"
      value = each.value.app_dir
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspecs/${each.value.buildspec_file}")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.this[each.key].name
    }
  }
}
