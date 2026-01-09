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
    key            = "952133486861/State/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    profile        = "backend"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet" {
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
  tags                              = {
    "Name"         = "IGW"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.VPC.id
  tags                              = {
    "Name"         = "RT"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT_IGW" {
  gateway_id             = aws_internet_gateway.IGW.id
  route_table_id         = aws_route_table.RT.id
  destination_cidr_block = "0.0.0.0/0"
}