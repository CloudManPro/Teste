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
    key            = "952133486861/State4/main.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "TableBE"
    profile        = "backend"
    encrypt        = true
  }
}

provider "aws" {
  region = "sa-east-1"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "archive_file" "archive_CloudMan_Function" {
  output_path = "${path.module}/CloudMan_Function.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/Python"
  type        = "zip"
}

resource "aws_lambda_function" "Function" {
  function_name                  = "Function"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function.output_path}"
  handler                        = "Python.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function.arn
  runtime                        = "python3.13"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function.output_base64sha256}"
  timeout                        = 30
  tags                              = {
    "Name"         = "Function"
    "State"        = "State4"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function2" {
  output_path = "${path.module}/CloudMan_Function2.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/Node"
  type        = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                  = "Function2"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function2.output_path}"
  handler                        = "Node.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function2.arn
  runtime                        = "nodejs24.x"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function2.output_base64sha256}"
  timeout                        = 30
  tags                              = {
    "Name"         = "Function2"
    "State"        = "State4"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function3" {
  output_path = "${path.module}/CloudMan_Function3.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/Ruby"
  type        = "zip"
}

resource "aws_lambda_function" "Function3" {
  function_name                  = "Function3"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function3.output_path}"
  handler                        = "Ruby.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function3.arn
  runtime                        = "ruby3.4"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function3.output_base64sha256}"
  timeout                        = 30
  tags                              = {
    "Name"         = "Function3"
    "State"        = "State4"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function" {
  name = "role_Function"
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
}

resource "aws_iam_role" "role_Function2" {
  name = "role_Function2"
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
}

resource "aws_iam_role" "role_Function3" {
  name = "role_Function3"
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
}