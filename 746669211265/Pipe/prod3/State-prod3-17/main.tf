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
    key            = "746669211265/Pipe/prod3/State-prod3-17/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    profile        = "backend"
    encrypt        = true
  }
}

provider "aws" {
  region = "sa-east-1"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_sns_topic" "Topic-prod3-17" {
  name                              = "Topic-prod3-17"
  tags                              = {
    "Name" = "Topic-prod3-17"
    "State" = "State-prod3-17"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod3"
  }
}

resource "aws_sns_topic" "Topic3-prod3-17" {
  name                              = "Topic3-prod3-17"
  tags                              = {
    "Name" = "Topic3-prod3-17"
    "State" = "State-prod3-17"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod3"
  }
}