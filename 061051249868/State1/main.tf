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

resource "aws_subnet" "Subnet3" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1d"
  cidr_block              = "10.2.3.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet3"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_ami" "AMI_Data_Source_Template" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Template" {
  image_id                          = data.aws_ami.AMI_Data_Source_Template.id
  name                              = "Template"
  description                       = "descript"
  disable_api_stop                  = false
  disable_api_termination           = false
  ebs_optimized                     = true
  instance_initiated_shutdown_behavior = "stop"
  instance_type                     = "t3.micro"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash


EOFUData
  )
  iam_instance_profile {
    name = aws_iam_instance_profile.profile_ASG.name
  }
  tags                              = {
    "Name"         = "Template"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_autoscaling_group" "ASG" {
  name                             = "ASG"
  capacity_rebalance               = true
  default_cooldown                 = 300
  default_instance_warmup          = 0
  desired_capacity                 = 8
  desired_capacity_type            = "units"
  force_delete                     = false
  force_delete_warm_pool           = false
  health_check_grace_period        = 300
  health_check_type                = "EC2"
  ignore_failed_scaling_activities = false
  max_instance_lifetime            = 0
  max_size                         = 8
  min_elb_capacity                 = 0
  min_size                         = 8
  protect_from_scale_in            = false
  vpc_zone_identifier              = [aws_subnet.Subnet3.id, aws_subnet.Subnet.id, aws_subnet.Subnet1.id, aws_subnet.Subnet4.id]
  wait_for_elb_capacity            = 0
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }
  launch_template {
    version = "$Latest"
    id      = aws_launch_template.Template.id
  }
}

resource "aws_subnet" "Subnet" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.0.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet1" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet4" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1c"
  cidr_block              = "10.2.2.0/24"
  map_public_ip_on_launch = false
  tags                              = {
    "Name"         = "Subnet4"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_ASG" {
  name = "role_ASG"
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

resource "aws_iam_instance_profile" "profile_ASG" {
  name = "profile_ASG"
  role = aws_iam_role.role_ASG.name
}