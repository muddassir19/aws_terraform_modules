output "rds_instance_id" {
  description = "RDS instance ID"
  value       = var.create ? aws_db_instance.rds_instance[0].id : null
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = var.create ? aws_db_instance.rds_instance[0].arn : null
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = var.create ? aws_db_instance.rds_instance[0].endpoint : null
}

output "rds_port" {
  description = "RDS port"
  value       = var.create ? aws_db_instance.rds_instance[0].port : null
}

output "security_group_id" {
  description = "Security group ID"
  value       = var.create && var.create_security_group && length(aws_security_group.rds_sg) > 0 ? aws_security_group.rds_sg[0].id : null
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value       = var.create && var.create_subnet_group && length(aws_db_subnet_group.rds_subnet_group) > 0 ? aws_db_subnet_group.rds_subnet_group[0].name : null
}

output "master_user_secret_arn" {
  description = "Master user secret ARN"
  value       = var.create && var.manage_master_user_password ? aws_db_instance.rds_instance[0].master_user_secret[0].secret_arn : null
}

output "availability_zone" {
  description = "Availability zone"
  value       = var.create && !var.multi_az ? aws_db_instance.rds_instance[0].availability_zone : null
}