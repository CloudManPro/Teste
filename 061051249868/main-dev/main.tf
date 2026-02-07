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
    key            = "061051249868/main-dev/main.tfstate"
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

resource "aws_vpc" "app-dev" {
  cidr_block                        = "10.11.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "app-dev"
    "State" = "main-dev"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW-dev" {
  vpc_id                            = aws_vpc.app-dev.id
  tags                              = {
    "Name" = "IGW-dev"
    "State" = "main-dev"
    "CloudmanUser" = "GlobalUserName"
  }
}


