terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

resource "aws_subnet" "public-a-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.12.0.0/26"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-a-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}


