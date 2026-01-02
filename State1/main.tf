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
    key            = "State1/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["746669211265"]
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_sns_topic" "Topic2" {
  name = "Topic2"
  tags                              = {
    "Name"         = "Topic2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}