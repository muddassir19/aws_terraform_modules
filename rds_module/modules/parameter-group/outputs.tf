output "parameter_group_id" {
  description = "ID of the parameter group"
  value       = var.create ? aws_db_parameter_group.this[0].id : null
}

output "parameter_group_name" {
  description = "Name of the parameter group"
  value       = var.create ? aws_db_parameter_group.this[0].name : null
}

output "parameter_group_arn" {
  description = "ARN of the parameter group"
  value       = var.create ? aws_db_parameter_group.this[0].arn : null
}