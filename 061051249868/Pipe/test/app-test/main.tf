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
    key            = "061051249868/Pipe/test/app-test/main.tfstate"
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

data "aws_internet_gateway" "IGW8" {
  filter {
    name                            = "tag:Name"
    values                          = ["IGW8"]
  }
}




### CATEGORY: NETWORK ###

resource "aws_subnet" "private-a-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.12.2.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "private-a-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_subnet" "private-b-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.12.4.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "private-b-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_subnet" "public-a-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.12.3.0/24"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-a-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_subnet" "public-b-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.12.5.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-b-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_route" "aws_route_RT11_test_IGW8" {
  gateway_id                        = data.aws_internet_gateway.IGW8.id
  route_table_id                    = aws_route_table.RT11-test.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT10-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  tags                              = {
    "Name" = "RT10-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_route_table" "RT11-test" {
  vpc_id                            = data.aws_vpc.app-test.id
  tags                              = {
    "Name" = "RT11-test"
    "State" = "app-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_a_test_RT10_test" {
  route_table_id                    = aws_route_table.RT10-test.id
  subnet_id                         = aws_subnet.private-a-test.id
}

resource "aws_route_table_association" "aws_route_table_association_private_b_test_RT10_test" {
  route_table_id                    = aws_route_table.RT10-test.id
  subnet_id                         = aws_subnet.private-b-test.id
}

resource "aws_route_table_association" "aws_route_table_association_public_a_test_RT11_test" {
  route_table_id                    = aws_route_table.RT11-test.id
  subnet_id                         = aws_subnet.public-a-test.id
}

resource "aws_route_table_association" "aws_route_table_association_public_b_test_RT11_test" {
  route_table_id                    = aws_route_table.RT11-test.id
  subnet_id                         = aws_subnet.public-b-test.id
}


