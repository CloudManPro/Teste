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
resource "aws_vpc" "VPC2" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet0" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.0.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet0"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_db_instance" "Database" {
  db_name                               = "test"
  db_subnet_group_name                  = aws_db_subnet_group.subnet_group_Database.name
  allocated_storage                     = 20
  availability_zone                     = aws_subnet.Subnet0.availability_zone
  backup_retention_period               = 7
  copy_tags_to_snapshot                 = true
  delete_automated_backups              = false
  engine                                = "mysql"
  engine_version                        = "8.0"
  instance_class                        = "db.t3.micro"
  iops                                  = 3000
  max_allocated_storage                 = 100
  password                              = "admin"
  performance_insights_retention_period = 7
  skip_final_snapshot                   = true
  storage_encrypted                     = true
  storage_throughput                    = 125
  storage_type                          = "gp3"
  upgrade_storage_config                = false
  username                              = "admin"
  tags                              = {
    "Name"         = "Database"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet1" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.2.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
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
  subnet_id                         = aws_subnet.Subnet2.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance.id
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance.name
  instance_type                     = "t3.micro"
  tenancy                           = "default"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
# --- END CLOUDMAN VARIABLES ---


EOFUData
  )
  user_data_replace_on_change = false
  tags                              = {
    "Name"         = "Instance"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet3" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.3.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet3"
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

resource "aws_db_subnet_group" "subnet_group_Database" {
  name       = "database-subnet-group"
  subnet_ids = [aws_subnet.Subnet0.id, aws_subnet.Subnet2.id, aws_subnet.Subnet1.id, aws_subnet.Subnet3.id]
  tags                              = {
    "Name"         = "subnet_group_Database"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}