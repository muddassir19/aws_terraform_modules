# Control Variables
variable "create" {
  description = "Whether to create RDS instance and associated resources"
  type        = bool
  default     = true
}

# Database Configuration
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "engine" {
  description = "Database engine type"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "license_model" {
  description = "License model for the database"
  type        = string
  default     = null
}

# Instance Configuration
variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp2"
}

# High Availability
variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

# Version Upgrades
variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

# Encryption
variable "encrypt_instance" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "encrypt_instance_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# External Groups (from separate modules)
variable "parameter_group_name" {
  description = "Name of parameter group from separate module"
  type        = string
  default     = null
}

variable "option_group_name" {
  description = "Name of option group from separate module"
  type        = string
  default     = null
}

# Authentication
variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Manage master user password with Secrets Manager"
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key ID for master user secret"
  type        = string
  default     = null
}

# Active Directory
variable "domain" {
  description = "Active Directory domain ID"
  type        = string
  default     = null
}

variable "domain_iam_role_name" {
  description = "IAM role name for AD integration"
  type        = string
  default     = null
}

# Maintenance
variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

# Network
variable "db_port" {
  description = "Database port"
  type        = string
  default     = ""
}

variable "create_subnet_group" {
  description = "Create DB subnet group"
  type        = bool
  default     = true
}

variable "existing_subnet_group_name" {
  description = "Existing DB subnet group name"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

# Security Group
variable "create_security_group" {
  description = "Create security group"
  type        = bool
  default     = true
}

variable "sg_ingress" {
  description = "Security group ingress rules"
  type        = list(any)
  default     = []
}

variable "sg_egress" {
  description = "Security group egress rules"
  type        = list(any)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach"
  type        = list(string)
  default     = []
}

# Secret Rotation
variable "manage_master_user_password_rotation" {
  description = "Enable secret rotation"
  type        = bool
  default     = false
}

variable "master_user_password_rotate_immediately" {
  description = "Rotate secret immediately"
  type        = bool
  default     = false
}

variable "master_user_password_rotation_automatically_after_days" {
  description = "Days between automatic rotations"
  type        = number
  default     = 30
}

variable "master_user_password_rotation_duration" {
  description = "Rotation window duration"
  type        = string
  default     = null
}

variable "master_user_password_rotation_schedule_expression" {
  description = "Rotation schedule expression"
  type        = string
  default     = null
}

# Role Associations
variable "rds_role_associations" {
  description = "List of role associations"
  type        = list(object({
    feature_name = string
    role_arn     = string
  }))
  default     = []
}

# Snapshot
variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

# Tags
variable "mandatory_tags" {
  description = "Mandatory tags for all resources"
  type        = map(string)
  nullable    = false
}

variable "rds_additional_tags" {
  description = "Additional tags for RDS resources"
  type        = map(string)
  default     = {}
}

variable "sg_additional_tags" {
  description = "Additional tags for security group"
  type        = map(string)
  default     = {}
}