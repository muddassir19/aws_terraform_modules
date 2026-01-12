# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "my-terraform-state"
#     key            = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment     = "production"
      ManagedBy       = "Terraform"
      Deployment      = "Gen2"
      CostCenter      = "12345"
      Application     = "myapp"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
EOF
}

inputs = {
  aws_region = "ap-south-1"
  
  # Common tags for all modules
  mandatory_tags = {
    CostCenter        = "12345"
    Dataclassification = "confidential"
    Application       = "myapp"
    Environment       = "prod"
    Function          = "database"
    CreatedThrough    = "Terraform"
    Deployment        = "Gen2"
  }
}