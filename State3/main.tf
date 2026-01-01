terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-teste-backend-terraform-cloudmantest"
    key            = "State3/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBEcloudmantest"
    encrypt        = true
  }
}

provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["061051249868"]
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_sns_topic" "Topic3" {
  name = "Topic3"
  tags                              = {
    "Name"         = "Topic3"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}