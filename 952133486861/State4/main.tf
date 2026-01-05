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

resource "aws_sns_topic" "Topic3-test" {
  name                              = "Topic3-test"
  tags                              = {
    "Name" = "Topic3-test"
    "State" = "State4-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "cldmn_tag" "tag_stage_Box1" {
  tags {
    key                             = "Stage"
    value                           = "test"
  }
}