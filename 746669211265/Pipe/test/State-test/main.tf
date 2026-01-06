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
  region = "sa-east-1"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_sns_topic" "Topic-test" {
  name                              = "Topic-test"
  tags                              = {
    "Name" = "Topic-test"
    "State" = "State-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}