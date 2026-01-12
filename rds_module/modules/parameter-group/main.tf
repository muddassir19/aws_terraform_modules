resource "aws_db_parameter_group" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  family      = var.family
  description = var.description
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = var.create ? var.family != null : true
      error_message = "parameter_group_family is required when creating a parameter group"
    }
  }
}