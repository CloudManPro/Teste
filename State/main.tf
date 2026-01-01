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
    key            = "State/main.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

provider "aws" {
  region              = "sa-east-1"
  allowed_account_ids = ["952133486861"]
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_sns_topic" "Topic1" {
  name = "Topic1"
  tags                              = {
    "Name"         = "Topic1"
    "State"        = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}