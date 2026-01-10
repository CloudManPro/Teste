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
    key            = "061051249868/State3/main.tfstate"
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
data "aws_ami" "AMI_Data_Source_Template1" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Template1" {
  image_id                          = data.aws_ami.AMI_Data_Source_Template1.id
  name                              = "Template1"
  ebs_optimized                     = true
  instance_type                     = "t3.micro"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
# --- END CLOUDMAN VARIABLES ---


EOFUData
  )
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 0
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  network_interfaces {
    associate_public_ip_address = "true"
  }
  tags                              = {
    "Name"         = "Template1"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_vpc" "VPC3" {
  cidr_block       = "10.3.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC3"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}