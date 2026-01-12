variable "create" {
  description = "Whether to create the parameter group. When false, existing group will be deleted if managed by Terraform."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the parameter group"
  type        = string
}

variable "family" {
  description = "DB parameter group family (e.g., mysql5.7, postgres10)"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the parameter group"
  type        = string
  default     = "Custom DB Parameter Group"
}

variable "parameters" {
  description = "A list of DB parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the parameter group"
  type        = map(string)
  default     = {}
}