# ---------------------------------------------------------------------------
# Lean RDS-only network for the FinCorp DR lab.
#
# FinCorp does NOT run the pongapp here (AGENTS.md §1). The only thing that
# lives in this VPC is the primary RDS PostgreSQL instance (Objective 2).
# CodeArtifact/CodeBuild/ECR are regional AWS services and need no VPC wiring.
#
# Cost/scope trade-off: RDS is private and has no outbound need, so this VPC
# intentionally has NO Internet Gateway and NO NAT Gateway (NAT bills hourly +
# per-GB). The data subnets are fully private with no default route to the
# internet. If a future need for egress arises (e.g. RDS -> external service),
# add an IGW + NAT or VPC endpoints then — not now.
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.name_prefix}-vpc" }
}

# ---- private data subnets (RDS requires >= 2 AZs) ----
resource "aws_subnet" "private_data" {
  count             = length(var.private_data_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_data_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  # Private by design: no public IPs auto-assigned, no route to an IGW/NAT.
  tags = {
    Name = "${var.name_prefix}-data-${var.azs[count.index]}"
    Tier = "private-data"
  }
}

# ---- DB subnet group spanning the private data subnets ----
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db"
  subnet_ids = aws_subnet.private_data[*].id
  tags       = { Name = "${var.name_prefix}-db-subnet-group" }
}

# ---------------------------------------------------------------------------
# RDS security group — PostgreSQL reachable only from within the VPC.
# ---------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "RDS PostgreSQL - ingress 5432 from within the VPC only"
  vpc_id      = aws_vpc.this.id
  tags        = { Name = "${var.name_prefix}-rds-sg" }
}

# Ingress: 5432 scoped to the VPC CIDR (never 0.0.0.0/0).
resource "aws_vpc_security_group_ingress_rule" "rds_postgres" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  description       = "PostgreSQL from within the VPC"
}

# Egress: scoped to the VPC CIDR to match the least-privilege ingress posture.
# (Effectively a no-op for reachability since there is no IGW/NAT, but it keeps
# the rule honest rather than advertising 0.0.0.0/0.)
resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
  description       = "Allow egress within the VPC"
}
