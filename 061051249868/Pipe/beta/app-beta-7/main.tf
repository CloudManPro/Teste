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
    key            = "061051249868/Pipe/beta/app-beta-7/main.tfstate"
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

data "aws_internet_gateway" "IGW9" {
  filter {
    name                            = "tag:Name"
    values                          = ["IGW9"]
  }
}




### CATEGORY: NETWORK ###

resource "aws_subnet" "private-a-beta-7" {
  vpc_id                            = data.aws_vpc.app-prod.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.13.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "private-a-beta-7"
    "State" = "app-beta-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "beta"
  }
}

resource "aws_subnet" "private-b-beta-7" {
  vpc_id                            = data.aws_vpc.app-prod.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.13.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "private-b-beta-7"
    "State" = "app-beta-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "beta"
  }
}

resource "aws_subnet" "public-a-beta-7" {
  vpc_id                            = data.aws_vpc.app-prod.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.13.2.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-a-beta-7"
    "State" = "app-beta-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "beta"
  }
}

resource "aws_subnet" "public-b-beta-7" {
  vpc_id                            = data.aws_vpc.app-prod.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.13.3.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-b-beta-7"
    "State" = "app-beta-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "beta"
  }
}

resource "aws_route" "aws_route_RT11_beta_7_IGW9" {
  gateway_id                        = data.aws_internet_gateway.IGW9.id
  route_table_id                    = aws_route_table.RT11-beta-7.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT10-beta-7" {
  vpc_id                            = data.aws_vpc.app-prod.id
  tags                              = {
    "Name" = "RT10-beta-7"
    "State" = "app-beta-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "beta"
  }
}

resource "aws_route_table" "RT11-beta-7" {
  vpc_id                            = data.aws_vpc.app-prod.id
  tags                              = {
    "Name" = "RT11-beta-7"
    "State" = "app-beta-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "beta"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_a_beta_7_RT10_beta_7" {
  route_table_id                    = aws_route_table.RT10-beta-7.id
  subnet_id                         = aws_subnet.private-a-beta-7.id
}

resource "aws_route_table_association" "aws_route_table_association_private_b_beta_7_RT10_beta_7" {
  route_table_id                    = aws_route_table.RT10-beta-7.id
  subnet_id                         = aws_subnet.private-b-beta-7.id
}

resource "aws_route_table_association" "aws_route_table_association_public_a_beta_7_RT11_beta_7" {
  route_table_id                    = aws_route_table.RT11-beta-7.id
  subnet_id                         = aws_subnet.public-a-beta-7.id
}

resource "aws_route_table_association" "aws_route_table_association_public_b_beta_7_RT11_beta_7" {
  route_table_id                    = aws_route_table.RT11-beta-7.id
  subnet_id                         = aws_subnet.public-b-beta-7.id
}


