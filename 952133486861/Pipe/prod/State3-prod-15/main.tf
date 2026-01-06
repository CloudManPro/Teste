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
    key            = "952133486861/Pipe/prod/State3-prod-15/main.tfstate"
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

resource "aws_sns_topic" "Topic2-prod-15" {
  name                              = "Topic2-prod-15"
  tags                              = {
    "Name" = "Topic2-prod-15"
    "State" = "State3-prod-15"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}