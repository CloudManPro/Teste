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
    key            = "061051249868/Pipe/test/db-test/main.tfstate"
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

data "aws_vpc" "app-test" {
  filter {
    name                            = "tag:Name"
    values                          = ["app-test"]
  }
}




### CATEGORY: NETWORK ###

resource "aws_subnet" "Subnet25-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.11.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet25-test"
    "State" = "db-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_subnet" "Subnet26-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.11.5.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet26-test"
    "State" = "db-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}


