output "primary_vault_name" {
  description = "Name of the us-east-1 source backup vault."
  value       = aws_backup_vault.primary.name
}

output "primary_vault_arn" {
  description = "ARN of the us-east-1 source backup vault."
  value       = aws_backup_vault.primary.arn
}

output "dr_vault_name" {
  description = "Name of the us-west-2 destination (cross-region copy) vault."
  value       = aws_backup_vault.dr.name
}

output "dr_vault_arn" {
  description = "ARN of the us-west-2 destination vault."
  value       = aws_backup_vault.dr.arn
}

output "plan_id" {
  description = "AWS Backup plan id."
  value       = aws_backup_plan.this.id
}

output "plan_arn" {
  description = "AWS Backup plan ARN."
  value       = aws_backup_plan.this.arn
}

output "backup_role_arn" {
  description = "ARN of the AWS Backup service role (used for on-demand jobs too)."
  value       = aws_iam_role.backup.arn
}

output "selection_id" {
  description = "AWS Backup selection id."
  value       = aws_backup_selection.rds.id
}
