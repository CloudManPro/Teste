terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto nao configurado. Usando estado local.
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["952133486861"]
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_sns_topic" "Topic" {
  name = "Topic"
  tags                              = {
    "Name"         = "Topic"
    "State"        = "State2"
    "CloudmanUser" = "GlobalUserName"
  }
}