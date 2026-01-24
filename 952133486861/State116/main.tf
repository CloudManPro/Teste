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
    key            = "952133486861/State116/main.tfstate"
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

### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "my-bucket1-cloudman-123" {
  bucket                            = "my-bucket1-cloudman-123"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket1-cloudman-123"
    "State" = "State116"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket1-cloudman-123_controls" {
  bucket                            = aws_s3_bucket.my-bucket1-cloudman-123.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "my-bucket1-cloudman-123_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket1-cloudman-123.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket1-cloudman-123_configuration" {
  bucket                            = aws_s3_bucket.my-bucket1-cloudman-123.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "my-bucket1-cloudman-123_versioning" {
  bucket                            = aws_s3_bucket.my-bucket1-cloudman-123.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_object" "Tretris_html" {
  source                            = "${path.module}/.external_modules/CloudMan/HTML/Tretris.html"
  bucket                            = aws_s3_bucket.my-bucket1-cloudman-123.bucket
  checksum_algorithm                = "CRC32"
  content_type                      = "application/octet-stream"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/HTML/Tretris.html")
  key                               = "Tretris.html"
  tags                              = {
    "Name" = "Tretris_html"
    "State" = "State116"
    "CloudmanUser" = "GlobalUserName"
  }
}


