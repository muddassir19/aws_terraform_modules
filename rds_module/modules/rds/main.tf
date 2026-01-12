# Data source for subnet (needed for availability_zone)
data "aws_subnet" "subnet" {
  count = var.create && !var.multi_az && length(var.subnet_ids) > 0 ? 1 : 0
  id    = var.subnet_ids[0]
}

# Creating a DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  count = var.create && var.create_subnet_group && var.existing_subnet_group_name == null ? 1 : 0

  name        = "${var.db_name}-sbng"
  description = "Custom DB Subnet Group for ${var.db_name} RDS"
  subnet_ids  = var.subnet_ids

  tags = merge(var.mandatory_tags, var.rds_additional_tags, 
    { Name = join("-", [var.db_name, "sbng"]) }, 
    { CreatedThrough = "Terraform" }, 
    { Deployment = "Gen2" }
  )
}

# Security Group
resource "aws_security_group" "rds_sg" {
  count = var.create && var.create_security_group && (length(var.sg_ingress) > 0 || length(var.sg_egress) > 0) ? 1 : 0

  name        = "${var.db_name}-sg"
  description = "Security Group for ${var.db_name} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.mandatory_tags, var.sg_additional_tags, 
    { Name = join("-", [var.db_name, "sg"]) }, 
    { CreatedThrough = "Terraform" }, 
    { Deployment = "Gen2" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "rds_sg_ingress" {
  count = var.create && var.create_security_group ? length(var.sg_ingress) : 0

  security_group_id = aws_security_group.rds_sg[0].id
  
  # Use coalesce for cleaner null handling
  description = lookup(var.sg_ingress[count.index], "description", null)
  ip_protocol = lookup(var.sg_ingress[count.index], "ip_protocol", null)
  
  # Fixed: Proper port logic
  from_port = lookup(var.sg_ingress[count.index], "from_port", 
    lookup(var.sg_ingress[count.index], "ip_protocol", "") == "-1" || 
    lookup(var.sg_ingress[count.index], "ip_protocol", "") == "icmpv6" ? null : 0
  )
  
  to_port = lookup(var.sg_ingress[count.index], "to_port", 
    lookup(var.sg_ingress[count.index], "ip_protocol", "") == "-1" || 
    lookup(var.sg_ingress[count.index], "ip_protocol", "") == "icmpv6" ? null : 65535
  )
  
  cidr_ipv4         = lookup(var.sg_ingress[count.index], "cidr_ipv4", null)
  cidr_ipv6         = lookup(var.sg_ingress[count.index], "cidr_ipv6", null)
  prefix_list_id    = lookup(var.sg_ingress[count.index], "prefix_list_id", null)
  referenced_security_group_id = lookup(var.sg_ingress[count.index], "referenced_security_group_id", null)

  tags = merge(var.mandatory_tags, var.sg_additional_tags, 
    { Name = join("-", ["${var.db_name}-sg", "igr", count.index]) }, 
    { CreatedThrough = "Terraform" }, 
    { Deployment = "Gen2" }
  )
}

resource "aws_vpc_security_group_egress_rule" "rds_sg_egress" {
  count = var.create && var.create_security_group ? length(var.sg_egress) : 0

  security_group_id = aws_security_group.rds_sg[0].id
  
  description = lookup(var.sg_egress[count.index], "description", null)
  ip_protocol = lookup(var.sg_egress[count.index], "ip_protocol", null)
  
  # FIXED: Use sg_egress, not sg_ingress
  from_port = lookup(var.sg_egress[count.index], "from_port", 
    lookup(var.sg_egress[count.index], "ip_protocol", "") == "-1" || 
    lookup(var.sg_egress[count.index], "ip_protocol", "") == "icmpv6" ? null : 0
  )
  
  to_port = lookup(var.sg_egress[count.index], "to_port", 
    lookup(var.sg_egress[count.index], "ip_protocol", "") == "-1" || 
    lookup(var.sg_egress[count.index], "ip_protocol", "") == "icmpv6" ? null : 65535
  )
  
  cidr_ipv4         = lookup(var.sg_egress[count.index], "cidr_ipv4", null)
  cidr_ipv6         = lookup(var.sg_egress[count.index], "cidr_ipv6", null)
  prefix_list_id    = lookup(var.sg_egress[count.index], "prefix_list_id", null)
  referenced_security_group_id = lookup(var.sg_egress[count.index], "referenced_security_group_id", null)

  tags = merge(var.mandatory_tags, var.sg_additional_tags, 
    { Name = join("-", ["${var.db_name}-sg", "eg", count.index]) }, 
    { CreatedThrough = "Terraform" }, 
    { Deployment = "Gen2" }
  )
}

# RDS Instance
resource "aws_db_instance" "rds_instance" {
  count = var.create ? 1 : 0

  # Database name
  db_name = local.supports_db_name ? var.db_name : null
  identifier = var.db_name
  
  # Engine configuration
  engine         = var.engine
  engine_version = var.engine_version
  license_model  = var.license_model
  
  # High availability
  multi_az = var.multi_az
  availability_zone = var.multi_az ? null : (
    length(data.aws_subnet.subnet) > 0 ? data.aws_subnet.subnet[0].availability_zone : null
  )
  
  # Version upgrades
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  
  # Storage
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.encrypt_instance
  kms_key_id        = var.encrypt_instance_key_id
  instance_class    = var.instance_class
  
  # External groups (from separate modules)
  option_group_name    = var.option_group_name
  parameter_group_name = var.parameter_group_name
  
  # Authentication
  username = var.db_username
  manage_master_user_password = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  
  # Active Directory
  domain = var.domain
  domain_iam_role_name = var.domain != null ? (
    var.domain_iam_role_name != null ? var.domain_iam_role_name : "rds-directoryservice-access-role"
  ) : null
  
  # Maintenance
  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window
  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot = true
  
  # Network
  port = var.db_port != "" ? var.db_port : null
  db_subnet_group_name = local.db_subnet_group_name
  vpc_security_group_ids = local.security_group_ids
  
  # Snapshot
  final_snapshot_identifier = "${var.db_name}-finalsnapshot"
  skip_final_snapshot = var.skip_final_snapshot
  
  # Tags
  tags = merge(var.mandatory_tags, var.rds_additional_tags, 
    { CreatedThrough = "Terraform" }, 
    { Deployment = "Gen2" }
  )
  
  # Dependencies
  depends_on = [
    aws_db_subnet_group.rds_subnet_group,
    aws_security_group.rds_sg
  ]
}

# Managed secret Rotation
resource "aws_secretsmanager_secret_rotation" "rds_secret_rotation" {
  count = var.create && var.manage_master_user_password_rotation ? 1 : 0

  secret_id           = aws_db_instance.rds_instance[0].master_user_secret[0].secret_arn
  rotate_immediately  = var.master_user_password_rotate_immediately

  rotation_rules {
    automatically_after_days = var.master_user_password_rotation_automatically_after_days
    duration                 = var.master_user_password_rotation_duration
    schedule_expression      = var.master_user_password_rotation_schedule_expression
  }
  
  lifecycle {
    precondition {
      condition     = var.manage_master_user_password_rotation ? var.manage_master_user_password == true : true
      error_message = "manage_master_user_password must be true when manage_master_user_password_rotation is enabled"
    }
  }
}

# Role Associations
resource "aws_db_instance_role_association" "rds_role_association" {
  count = var.create ? length(var.rds_role_associations) : 0

  db_instance_identifier = aws_db_instance.rds_instance[0].identifier
  feature_name           = var.rds_role_associations[count.index].feature_name
  role_arn               = var.rds_role_associations[count.index].role_arn
}

# Locals for conditional logic
locals {
  # Check if engine supports db_name parameter
  supports_db_name = !contains([
    "oracle-ee", "oracle-se", "oracle-se1", "oracle-se2",
    "sqlserver-ee", "sqlserver-ex", "sqlserver-se", "sqlserver-web"
  ], var.engine)
  
  # Determine subnet group name
  db_subnet_group_name = var.create_subnet_group ? (
    var.existing_subnet_group_name != null ? var.existing_subnet_group_name : (
      length(aws_db_subnet_group.rds_subnet_group) > 0 ? aws_db_subnet_group.rds_subnet_group[0].name : null
    )
  ) : var.existing_subnet_group_name
  
  # Determine security group IDs - FIXED variable names
  security_group_ids = var.create_security_group ? (
    length(aws_security_group.rds_sg) > 0 ? concat([aws_security_group.rds_sg[0].id], var.additional_security_group_ids) : var.additional_security_group_ids
  ) : var.additional_security_group_ids
}