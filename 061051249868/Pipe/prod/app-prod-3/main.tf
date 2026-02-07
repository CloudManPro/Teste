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
    key            = "061051249868/Pipe/prod/app-prod-3/main.tfstate"
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

### EXTERNAL REFERENCES ###

data "aws_vpc" "app-prod" {
  filter {
    name                            = "tag:Name"
    values                          = ["app-prod"]
  }
}




### CATEGORY: NETWORK ###

resource "aws_subnet" "public-a-prod-3" {
  vpc_id                            = data.aws_vpc.app-prod.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.13.0.0/26"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-a-prod-3"
    "State" = "app-prod-3"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}


