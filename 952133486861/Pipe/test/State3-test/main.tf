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
    key            = "952133486861/Pipe/test/State3-test/main.tfstate"
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
resource "aws_sns_topic" "Topic2-test" {
  name = "Topic2-test"
  tags                              = {
    "Name"         = "Topic2-test"
    "State"        = "State3-test"
    "CloudmanUser" = "GlobalUserName"
    "Stage"        = "test"
  }
}