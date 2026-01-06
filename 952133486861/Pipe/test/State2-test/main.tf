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

resource "aws_sns_topic" "Topic4-test" {
  name                              = "Topic4-test"
  tags                              = {
    "Name" = "Topic4-test"
    "State" = "State2-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}