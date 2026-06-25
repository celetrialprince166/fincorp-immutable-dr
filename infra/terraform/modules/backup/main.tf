# ===========================================================================
# AWS Backup — daily RDS snapshot in us-east-1 + cross-region copy to us-west-2.
#
# Why AWS Backup over RDS native cross-region snapshot copy: centralised,
# policy-driven, auditable, and extensible to other services — the FinCorp
# "auditable supply chain / DR" posture. The copy_action is the core DR
# mechanism: every recovery point is replicated into the us-west-2 vault so a
# region failure can be recovered there.
# ===========================================================================

# --- Source vault (us-east-1, default provider) ----------------------------
resource "aws_backup_vault" "primary" {
  name = "${var.name_prefix}-vault-use1"
  tags = { Name = "${var.name_prefix}-vault-use1" }
}

# --- Destination vault (DR region, aws.usw2 alias) -------------------------
# The aws.usw2 alias points at the SCP-allowed DR region (ev: eu-west-1).
resource "aws_backup_vault" "dr" {
  provider = aws.usw2
  name     = "${var.name_prefix}-vault-dr"
  tags     = { Name = "${var.name_prefix}-vault-dr" }
}

# ---------------------------------------------------------------------------
# Least-privilege AWS Backup service role. Trust = backup.amazonaws.com.
# Attaches ONLY the AWS-managed backup + restore policies (restore is needed in
# Phase 5). Cross-region copy permissions are included in the backup managed
# policy. No inline "*:*" — managed policies are scoped to backup/restore APIs.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${var.name_prefix}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = { Name = "${var.name_prefix}-backup-role" }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# --- Backup plan: daily rule + cross-region copy_action --------------------
resource "aws_backup_plan" "this" {
  name = "${var.name_prefix}-daily-plan"

  rule {
    rule_name         = "daily-with-cross-region-copy"
    target_vault_name = aws_backup_vault.primary.name
    schedule          = var.schedule
    start_window      = var.start_window_minutes
    completion_window = var.completion_window_minutes

    lifecycle {
      delete_after = var.delete_after_days
    }

    # The cross-region copy — recovery points land in the us-west-2 vault.
    copy_action {
      destination_vault_arn = aws_backup_vault.dr.arn
      lifecycle {
        delete_after = var.copy_delete_after_days
      }
    }
  }

  tags = { Name = "${var.name_prefix}-daily-plan" }
}

# --- Selection: target the RDS instance by tag -----------------------------
resource "aws_backup_selection" "rds" {
  name         = "${var.name_prefix}-rds-selection"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.this.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}
