variable "name_prefix" {
  description = "Prefix for resource names (e.g. fincorp-prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC; also the ingress scope for the RDS security group."
  type        = string
}

variable "azs" {
  description = "Availability zones for the private data subnets (>= 2 for RDS)."
  type        = list(string)
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks for the private data subnets, one per AZ in var.azs."
  type        = list(string)
}
