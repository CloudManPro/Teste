terraform {
  required_version = ">= 1.0.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-teste-backend-terraform"
    key            = "061051249868/State26/main.tfstate"
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

### CATEGORY: IAM ###

resource "aws_iam_role" "role_Function14" {
  name                              = "role_Function14"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_Function14"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC7" {
  assign_generated_ipv6_cidr_block  = true
  cidr_block                        = "10.6.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC7"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet16" {
  vpc_id                            = aws_vpc.VPC7.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.6.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet16"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet17" {
  vpc_id                            = aws_vpc.VPC7.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.6.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet17"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group" "SG1" {
  name                              = "SG1"
  vpc_id                            = aws_vpc.VPC7.id
  revoke_rules_on_delete            = false
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
  ingress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
    self                            = false
    to_port                         = 0
  }
  tags                              = {
    "Name" = "SG1"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group" "SG2" {
  name                              = "SG2"
  vpc_id                            = aws_vpc.VPC7.id
  revoke_rules_on_delete            = false
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
  tags                              = {
    "Name" = "SG2"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function14" {
  output_path                       = "${path.module}/CloudMan_Function14.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function14" {
  function_name                     = "Function14"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function14.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function14.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function14.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function14"
  }
  }
  tags                              = {
    "Name" = "Function14"
    "State" = "State26"
    "CloudmanUser" = "GlobalUserName"
  }
  vpc_config {
    ipv6_allowed_for_dual_stack     = true
    security_group_ids              = [aws_security_group.SG1.id, aws_security_group.SG2.id]
    subnet_ids                      = [aws_subnet.Subnet16.id, aws_subnet.Subnet17.id]
  }
}


