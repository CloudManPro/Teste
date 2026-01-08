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
data "archive_file" "archive_CloudMan_Function" {
  output_path = "${path.module}/CloudMan_Function.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub"
  type        = "zip"
}

resource "aws_lambda_function" "Function" {
  function_name                  = "Function"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function.output_path}"
  handler                        = "LambdaHub.lambda_handler"
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
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/APITest"
  type        = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                  = "Function2"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function2.output_path}"
  handler                        = "APITest.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function2.arn
  runtime                        = "python3.13"
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
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub"
  type        = "zip"
}

resource "aws_lambda_function" "Function3" {
  function_name                  = "Function3"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function3.output_path}"
  handler                        = "LambdaHub.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function3.arn
  runtime                        = "python3.13"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function3.output_base64sha256}"
  timeout                        = 30
  tags                              = {
    "Name"         = "Function3"
    "State"        = "State4"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_Dicionarios_Function4" {
  output_path = "${path.module}/Dicionarios_Function4.zip"
  source_dir  = "${path.module}/.external_modules/Dicionarios/DBAccess"
  type        = "zip"
}

resource "aws_lambda_function" "Function4" {
  function_name                  = "Function4"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_Dicionarios_Function4.output_path}"
  handler                        = "DBAccess.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function4.arn
  runtime                        = "python3.13"
  source_code_hash               = "${data.archive_file.archive_Dicionarios_Function4.output_base64sha256}"
  timeout                        = 30
  tags                              = {
    "Name"         = "Function4"
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

resource "aws_iam_role" "role_Function4" {
  name = "role_Function4"
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