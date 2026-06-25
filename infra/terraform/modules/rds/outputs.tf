output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.identifier
}

output "arn" {
  description = "RDS instance ARN (AWS Backup selection targets this)."
  value       = aws_db_instance.this.arn
}

output "address" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "RDS endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

# RDS-managed master credential secret — ARN ONLY, never the value. The value
# lives in Secrets Manager (KMS-encrypted) and is never read by Terraform.
output "master_user_secret_arn" {
  description = "ARN of the RDS-managed master-user secret in Secrets Manager."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
