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
    key            = "952133486861/State5-prod-7/main.tfstate"
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

resource "aws_sns_topic" "Topic4-prod-7" {
  name                              = "Topic4-prod-7"
  tags                              = {
    "Name" = "Topic4-prod-7"
    "State" = "State5-prod-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}

resource "aws_sns_topic" "Topic6-prod-7" {
  name                              = "Topic6-prod-7"
  tags                              = {
    "Name" = "Topic6-prod-7"
    "State" = "State5-prod-7"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}