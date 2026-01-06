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
    key            = "952133486861/Pipe/prod3/State3-prod3-17/main.tfstate"
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

resource "aws_sns_topic" "Topic2-prod3-17" {
  name                              = "Topic2-prod3-17"
  tags                              = {
    "Name" = "Topic2-prod3-17"
    "State" = "State3-prod3-17"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod3"
  }
}

resource "aws_sns_topic" "Topic1-prod3-17" {
  name                              = "Topic1-prod3-17"
  tags                              = {
    "Name" = "Topic1-prod3-17"
    "State" = "State3-prod3-17"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod3"
  }
}