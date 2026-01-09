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
    key            = "061051249868/State1/main.tfstate"
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
resource "aws_vpc" "VPC1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                  = aws_vpc.VPC1.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW1" {
  vpc_id = aws_vpc.VPC1.id
  tags                              = {
    "Name"         = "IGW1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.VPC1.id
  tags                              = {
    "Name"         = "RT1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet3" {
  vpc_id                  = aws_vpc.VPC1.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet3"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "local_file" "UserData_Instance" {
  filename = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Instance" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance" {
  subnet_id                         = aws_subnet.Subnet3.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance.id
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance.name
  instance_type                     = "t3.micro"
  tenancy                           = "default"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Instance.content}
EOFUData
  )
  user_data_replace_on_change = false
  tags                              = {
    "Name"         = "Instance"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Instance" {
  name = "role_Instance"
  assume_role_policy                = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
    ]
  })
}

resource "aws_iam_instance_profile" "profile_Instance" {
  name = "profile_Instance"
  role = aws_iam_role.role_Instance.name
}

resource "aws_route" "aws_route_RT1_IGW1" {
  gateway_id             = aws_internet_gateway.IGW1.id
  route_table_id         = aws_route_table.RT1.id
  destination_cidr_block = "0.0.0.0/0"
}