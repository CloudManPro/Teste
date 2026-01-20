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
    key            = "061051249868/State15/main.tfstate"
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

### EXTERNAL REFERENCES ###

data "aws_api_gateway_rest_api" "RestAPI3" {
  name                              = "RestAPI3"
}




### CATEGORY: IAM ###

resource "aws_iam_role" "role_Function5" {
  name                              = "role_Function5"
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
    "Name" = "role_Function5"
    "State" = "State15"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function5" {
  output_path                       = "${path.module}/CloudMan_Function5.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function5" {
  function_name                     = "Function5"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function5.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function5.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function5.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function5"
  }
  }
  tags                              = {
    "Name" = "Function5"
    "State" = "State15"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lambda_permission" "perm_RestAPI3_to_Function5" {
  function_name                     = aws_lambda_function.Function5.function_name
  statement_id                      = "perm_RestAPI3_to_Function5"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${data.aws_api_gateway_rest_api.RestAPI3.execution_arn}/*/*"
}


