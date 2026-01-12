include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modified_rds_module/option-group"
}

inputs = {
  create = false  # Set to false to delete this option group
  
  name                  = "prod-mysql-options"
  engine_name           = "mysql"
  major_engine_version  = "8.0"
  description           = "Production MySQL option group"
  
  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        }
      ]
    }
  ]
  
  tags = {
    Environment = "production"
    Engine      = "mysql"
    Version     = "8.0"
  }
}