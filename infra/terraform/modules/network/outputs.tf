output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "private_data_subnet_ids" {
  description = "IDs of the private data subnets (for RDS / DB subnet group)."
  value       = aws_subnet.private_data[*].id
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = aws_db_subnet_group.this.name
}

output "rds_sg_id" {
  description = "ID of the RDS PostgreSQL security group."
  value       = aws_security_group.rds.id
}
