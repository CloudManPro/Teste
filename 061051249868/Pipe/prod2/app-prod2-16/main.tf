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
    key            = "061051249868/Pipe/prod2/app-prod2-16/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic6-prod2-16" {
  name                              = "Topic6-prod2-16.fifo"
  fifo_topic                        = true
  tags                              = {
    "Name" = "Topic6-prod2-16"
    "State" = "app-prod2-16"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod2"
  }
}


