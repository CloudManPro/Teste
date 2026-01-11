terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto nao configurado.
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

resource "aws_subnet" "Subnetj" {
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnetj"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "local_file" "UserData_Instance2" {
  filename = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Instance2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance2" {
  subnet_id                         = aws_subnet.Subnetj.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance2.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance2.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Instance2.content}
EOFUData
  )
  user_data_replace_on_change = false
  vpc_security_group_ids      = [aws_security_group.SG.id]
  tags                              = {
    "Name"         = "Instance2"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group" "SG" {
  name                   = "SG"
  vpc_id                 = aws_vpc.VPC.id
  revoke_rules_on_delete = false
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }
  tags                              = {
    "Name"         = "SG"
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

resource "aws_iam_role" "role_Instance2" {
  name = "role_Instance2"
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

resource "aws_iam_instance_profile" "profile_Instance2" {
  name = "profile_Instance2"
  role = aws_iam_role.role_Instance2.name
}

resource "aws_route_table_association" "aws_route_table_association_Subnetj_RT" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.Subnetj.id
}

resource "aws_route" "aws_route_RT_IGW" {
  gateway_id             = aws_internet_gateway.IGW.id
  route_table_id         = aws_route_table.RT.id
  destination_cidr_block = "0.0.0.0/0"
}