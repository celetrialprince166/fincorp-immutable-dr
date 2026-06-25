# ---------------------------------------------------------------------------
# Amazon RDS PostgreSQL — the protected primary database (us-east-1).
#
# Credentials: manage_master_user_password = true. RDS creates AND rotates the
# master password in Secrets Manager (KMS-encrypted with the aws/secretsmanager
# key) on our behalf. Trade-off: the password value never enters Terraform code,
# state, or git — strictly better than a self-managed random_password whose
# .result lands in state. We only ever expose the secret ARN, never the value.
#
# Single-AZ: cost-optimized for the lab. Trade-off vs Multi-AZ — no automatic
# standby failover, but DR here is proven by the CROSS-REGION AWS Backup copy +
# restore drill (Objective 2), not by in-region HA, so Single-AZ is acceptable.
#
# Phase 5 simulates a region failure by DELETING this instance. Therefore:
#   deletion_protection = false   (so the drill can delete it)
#   skip_final_snapshot = true    (no final snapshot — the whole point is to
#                                  recover from the cross-region BACKUP copy,
#                                  not from a same-region final snapshot)
# ---------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true # default aws/rds KMS key (no customer CMK for the lab)

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  # RDS-managed master credential in Secrets Manager (KMS-encrypted, rotatable).
  manage_master_user_password = true

  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [var.rds_sg_id]
  multi_az                = var.multi_az
  publicly_accessible     = false # private data subnets only, no public IP
  backup_retention_period = var.backup_retention_period

  # See header: Phase 5 deletes this to simulate region failure.
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.name_prefix}-postgres"
    # AWS Backup selection targets this tag (see modules/backup).
    Backup = var.backup_tag_value
  }
}
