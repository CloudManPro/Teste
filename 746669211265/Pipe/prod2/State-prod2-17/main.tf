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
    key            = "746669211265/Pipe/prod2/State-prod2-17/main.tfstate"
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

resource "aws_sns_topic" "Topic-prod2-17" {
  name                              = "Topic-prod2-17"
  tags                              = {
    "Name" = "Topic-prod2-17"
    "State" = "State-prod2-17"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod2"
  }
}

resource "aws_sns_topic" "Topic3-prod2-17" {
  name                              = "Topic3-prod2-17"
  tags                              = {
    "Name" = "Topic3-prod2-17"
    "State" = "State-prod2-17"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod2"
  }
}