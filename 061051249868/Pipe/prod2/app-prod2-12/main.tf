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
    key            = "061051249868/Pipe/prod2/app-prod2-12/main.tfstate"
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

resource "aws_sns_topic" "Topic6-prod2-12" {
  name                              = "Topic6-prod2-12"
  lambda_success_feedback_sample_rate = 2
  signature_version                 = 2
  sqs_success_feedback_sample_rate  = 2
  tags                              = {
    "Name" = "Topic6-prod2-12"
    "State" = "app-prod2-12"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod2"
  }
}

resource "aws_sns_topic" "Topic8-prod2-12" {
  name                              = "Topic8-prod2-12.fifo"
  application_success_feedback_sample_rate = 2
  content_based_deduplication       = true
  fifo_throughput_scope             = "MessageGroup"
  fifo_topic                        = true
  firehose_success_feedback_sample_rate = 5
  signature_version                 = 2
  tags                              = {
    "Name" = "Topic8-prod2-12"
    "State" = "app-prod2-12"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod2"
  }
}


