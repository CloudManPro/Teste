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
    key            = "061051249868/State6/main.tfstate"
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

data "aws_iam_policy_document" "lambda_function_Function3_st_State6_doc" {
  statement {
    sid                             = "AllowSNSPublish"
    effect                          = "Allow"
    actions                         = ["sns:Publish"]
    resources                       = ["${aws_sns_topic.Topic.arn}"]
  }
}

resource "aws_iam_policy" "lambda_function_Function3_st_State6" {
  name                              = "lambda_function_Function3_st_State6"
  description                       = "Access Policy for Function3 in State6"
  policy                            = data.aws_iam_policy_document.lambda_function_Function3_st_State6_doc.json
}




### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic" {
  name                              = "Topic.fifo"
  content_based_deduplication       = true
  fifo_throughput_scope             = "Topic"
  fifo_topic                        = true
  tags                              = {
    "Name" = "Topic"
    "State" = "State6"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_sns_topic" "Topic1" {
  name                              = "Topic1"
  tags                              = {
    "Name" = "Topic1"
    "State" = "State6"
    "CloudmanUser" = "GlobalUserName"
  }
}


