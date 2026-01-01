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
  region = "None"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}