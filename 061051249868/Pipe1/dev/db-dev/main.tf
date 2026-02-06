terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-teste-backend-terraform"
    key            = "061051249868/Pipe1/dev/db-dev/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: STORAGE ###

resource "aws_dynamodb_table" "Table-dev" {
  name                              = "Table-dev"
  billing_mode                      = "PROVISIONED"
  deletion_protection_enabled       = false
  hash_key                          = "ID"
  read_capacity                     = 1
  stream_enabled                    = false
  table_class                       = "STANDARD"
  write_capacity                    = 1
  attribute {
    name                            = "ID"
    type                            = "S"
  }
  tags                              = {
    "Name" = "Table-dev"
    "State" = "db-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
}


