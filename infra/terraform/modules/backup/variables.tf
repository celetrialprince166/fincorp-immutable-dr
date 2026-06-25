variable "name_prefix" {
  description = "Prefix for backup resources (e.g. fincorp-prod)."
  type        = string
}

variable "rds_instance_arn" {
  description = "ARN of the RDS instance to back up (the selection target)."
  type        = string
}

variable "backup_tag_key" {
  description = "Tag key the backup selection matches on the RDS instance."
  type        = string
  default     = "Backup"
}

variable "backup_tag_value" {
  description = "Tag value the backup selection matches."
  type        = string
  default     = "fincorp-daily"
}

variable "schedule" {
  description = "Cron schedule for the daily backup rule (UTC)."
  type        = string
  default     = "cron(0 5 * * ? *)" # 05:00 UTC daily
}

variable "delete_after_days" {
  description = "Days after which recovery points are deleted (lifecycle)."
  type        = number
  default     = 14
}

variable "copy_delete_after_days" {
  description = "Days after which the us-west-2 copied recovery points are deleted."
  type        = number
  default     = 14
}

variable "start_window_minutes" {
  description = "Minutes Backup waits to start a job before marking it missed."
  type        = number
  default     = 60
}

variable "completion_window_minutes" {
  description = "Minutes a backup job is allowed to run before being canceled."
  type        = number
  default     = 180
}
