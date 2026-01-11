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
    key            = "061051249868/State/main.tfstate"
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
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnetnew" {
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnetnew"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "local_file" "UserData_Instance1" {
  filename = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Instance1" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance1" {
  subnet_id                         = aws_subnet.Subnetnew.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance1.id
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance1.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Instance1.content}
EOFUData
  )
  user_data_replace_on_change = false
  tags                              = {
    "Name"         = "Instance1"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb" "ALB" {
  name               = "ALB"
  idle_timeout       = 60
  load_balancer_type = "application"
  subnets            = [aws_subnet.Subnet2.id, aws_subnet.Subnet5.id]
  tags                              = {
    "Name"         = "ALB"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener" "Listener" {
  load_balancer_arn                    = aws_lb.ALB.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.TargetGroup.arn
    type             = "forward"
  }
  tags                              = {
    "Name"         = "Listener"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TargetGroup" {
  name                          = "TargetGroup"
  vpc_id                        = aws_vpc.VPC.id
  connection_termination        = false
  deregistration_delay          = "300"
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  port                          = 80
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  proxy_protocol_v2             = false
  slow_start                    = 0
  target_type                   = "instance"
  tags                              = {
    "Name"         = "TargetGroup"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.1.3.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet2"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet5" {
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet5"
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

resource "aws_iam_role" "role_Instance1" {
  name = "role_Instance1"
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

resource "aws_iam_instance_profile" "profile_Instance1" {
  name = "profile_Instance1"
  role = aws_iam_role.role_Instance1.name
}

resource "aws_route_table_association" "aws_route_table_association_Subnet2_RT" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.Subnet2.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet5_RT" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.Subnet5.id
}

resource "aws_route" "aws_route_RT_IGW" {
  gateway_id             = aws_internet_gateway.IGW.id
  route_table_id         = aws_route_table.RT.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_lb_target_group_attachment" "attach_Instance1_to_TargetGroup" {
  target_id        = aws_instance.Instance1.id
  port             = 80
  target_group_arn = aws_lb_target_group.TargetGroup.arn
}