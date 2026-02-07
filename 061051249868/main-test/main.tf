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
    key            = "061051249868/main-test/main.tfstate"
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

### CATEGORY: NETWORK ###

resource "aws_vpc" "app-test" {
  cidr_block                        = "10.12.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "app-test"
    "State" = "main-test"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW8" {
  vpc_id                            = aws_vpc.app-test.id
  tags                              = {
    "Name" = "IGW8"
    "State" = "main-test"
    "CloudmanUser" = "GlobalUserName"
  }
}


