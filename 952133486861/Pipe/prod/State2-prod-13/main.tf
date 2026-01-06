terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto nao configurado.
}

provider "aws" {
  region = "us-east-1"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_sns_topic" "Topic1-prod-13" {
  name                              = "Topic1-prod-13"
  tags                              = {
    "Name" = "Topic1-prod-13"
    "State" = "State2-prod-13"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}