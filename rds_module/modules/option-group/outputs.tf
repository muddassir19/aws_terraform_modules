output "option_group_id" {
  description = "ID of the option group"
  value       = var.create ? aws_db_option_group.this[0].id : null
}

output "option_group_name" {
  description = "Name of the option group"
  value       = var.create ? aws_db_option_group.this[0].name : null
}

output "option_group_arn" {
  description = "ARN of the option group"
  value       = var.create ? aws_db_option_group.this[0].arn : null
}