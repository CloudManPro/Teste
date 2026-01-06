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
    key            = "746669211265/Pipe/test/State5-test/main.tfstate"
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

resource "aws_sns_topic" "Topic4-test" {
  name                              = "Topic4-test"
  tags                              = {
    "Name" = "Topic4-test"
    "State" = "State5-test"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "test"
  }
}