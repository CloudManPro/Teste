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
    key            = "061051249868/State/main.tfstate"
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

### CATEGORY: IAM ###

resource "aws_secretsmanager_secret" "Secret" {
  name                              = "Secret"
  force_overwrite_replica_secret    = false
  recovery_window_in_days           = 0
  replica {
  }
  tags                              = {
    "Name" = "Secret"
    "State" = "State"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_secretsmanager_secret_version" "SecVersion" {
  secret_id                         = aws_secretsmanager_secret.Secret.id
  version_stages                    = ["AWSCURRENT"]
}


