resource "aws_db_option_group" "this" {
  count = var.create ? 1 : 0

  name                     = var.name
  option_group_description = var.description
  engine_name              = var.engine_name
  major_engine_version     = var.major_engine_version
  tags                     = var.tags

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name
      port        = lookup(option.value, "port", null)
      version     = lookup(option.value, "version", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = var.create ? (var.engine_name != null && var.major_engine_version != null) : true
      error_message = "engine_name and major_engine_version are required when creating an option group"
    }
  }
}