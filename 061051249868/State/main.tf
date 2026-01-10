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
    http_tokens = "required"
  }
  tags                              = {
    "Name"         = "Template1"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_vpc" "VPC" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}