include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Dependencies on separate modules
# Dependencies
dependency "parameter_group" {
  config_path = "../parameter-group"
  
  # Optional: Configure mock outputs for plan
  mock_outputs = {
    parameter_group_name = "mock-parameter-group"
  }
}

dependency "option_group" {
  config_path = "../option-group"
  
  mock_outputs = {
    option_group_name = "mock-option-group"
  }
}

terraform {
  source = "../../../modified_rds_module/rds"
}

inputs = {
  create = false
  
  # Database configuration
  db_name = "myappdb"
  engine = "mysql"
  engine_version = "8.0"
  major_engine_version = "8.0"
  storage_type = "gp3"
  license_model = "general-public-license"
  
  # Instance
  instance_class = "db.r5.xlarge"
  allocated_storage = 100
  multi_az = true
  
  # Authentication
  db_username = "admin"
  manage_master_user_password = true
  
  # Network
  vpc_id =  "vpc-0cf905897b49c5448" #"vpc-12345678"
  subnet_ids =  ["subnet-0f6d9c7491fe1c1b7", "subnet-0d857dc7bd16bfc3f"] #["subnet-123", "subnet-456"]
  
  # Security group rules
  sg_ingress = [
    {
      description = "MySQL access"
      from_port   = 3306
      to_port     = 3306
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16"
    }
  ]
  
  sg_egress = [
    {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
  
  # External groups from dependencies
  parameter_group_name = dependency.parameter_group.outputs.parameter_group_name
  option_group_name = dependency.option_group.outputs.option_group_name
  
  # Tags
  mandatory_tags = {
    CostCenter        = "12345"
    Dataclassification = "confidential"
    Application       = "myapp"
    Environment       = "prod"
    Function          = "database"
  }
}
