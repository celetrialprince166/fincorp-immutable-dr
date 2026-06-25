variable "name_prefix" {
  description = "Prefix for the DB identifier (e.g. fincorp-prod)."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL major engine version."
  type        = string
  default     = "17"
}

variable "instance_class" {
  description = "RDS instance class (cost-optimized default)."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (gp3)."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "fincorp_db"
}

variable "db_username" {
  description = "Master username (password is RDS-managed in Secrets Manager)."
  type        = string
  default     = "fincorp_admin"
}

variable "db_subnet_group_name" {
  description = "DB subnet group name (from the network module)."
  type        = string
}

variable "rds_sg_id" {
  description = "Security group id for the RDS instance (from the network module)."
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ (off by default for cost; DR is cross-region instead)."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Automated backup retention in days (RDS native, separate from AWS Backup)."
  type        = number
  default     = 1
}

variable "backup_tag_value" {
  description = "Value of the Backup tag the AWS Backup selection targets."
  type        = string
  default     = "fincorp-daily"
}
