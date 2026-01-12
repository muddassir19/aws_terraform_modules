include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modified_rds_module/parameter-group"
}

inputs = {
  create = false  # Set to false to delete this parameter group
  
  name        = "prod-mysql-8-params"
  family      = "mysql8.0"
  description = "Production MySQL 8.0 parameter group"
  
  parameters = [
    {
      name         = "max_connections"
      value        = "1000"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name         = "innodb_buffer_pool_size"
      value        = "{DBInstanceClassMemory*3/4}"
      apply_method = "pending-reboot"
    }
  ]
  
  tags = {
    Environment = "production"
    Engine      = "mysql"
    Version     = "8.0"
  }
}