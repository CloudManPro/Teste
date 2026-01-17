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

resource "aws_sns_topic" "Topic" {
  name                              = "Topic"
  tags                              = {
    "Name" = "Topic"
    "State" = "State6"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_iam_policy_document" "policy_Function3_st_State6_doc" {
  statement {
    sid                             = "AllowSNSPublish"
    effect                          = "Allow"
    actions                         = ["sns:Publish"]
    resources                       = ["${aws_sns_topic.Topic.arn}"]
  }
}

resource "aws_iam_policy" "policy_Function3_st_State6" {
  name                              = "policy_Function3_st_State6"
  description                       = "Combined Policy for Function3 in state State6"
  policy                            = data.aws_iam_policy_document.policy_Function3_st_State6_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_Function3_st_State6_attach" {
  policy_arn                        = aws_iam_policy.policy_Function3_st_State6.arn
  role                              = data.aws_iam_role.role_Function3.name
}

data "aws_iam_role" "role_Function3" {
  name                              = "role_Function3"
}