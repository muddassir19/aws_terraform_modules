variable "create" {
  description = "Whether to create the option group. When false, existing group will be deleted if managed by Terraform."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the option group"
  type        = string
}

variable "description" {
  description = "Description of the option group"
  type        = string
  default     = "Custom DB Option Group"
}

variable "engine_name" {
  description = "Database engine name (e.g., mysql, postgres, sqlserver-ee)"
  type        = string
  default     = null
}

variable "major_engine_version" {
  description = "Major engine version (e.g., 5.7, 10.0)"
  type        = string
  default     = null
}

variable "options" {
  description = "A list of DB Options to apply"
  type = list(object({
    option_name = string
    port        = optional(number)
    version     = optional(string)
    db_security_group_memberships  = optional(list(string))
    vpc_security_group_memberships = optional(list(string))
    option_settings = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the option group"
  type        = map(string)
  default     = {}
}