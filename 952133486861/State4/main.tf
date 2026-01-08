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
    bucket         = "bucket-teste-backend-terraform-a-bbb"
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
  source_dir  = "${path.module}/LambdaFiles/LambdaHub"
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