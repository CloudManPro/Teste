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
    key            = "952133486861/State4/main.tfstate"
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
resource "aws_sqs_queue" "Queue" {
  name                              = "Queue"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags                              = {
    "Name"         = "Queue"
    "State"        = "State4"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket" "s3-cloudman-12345" {
  bucket              = "s3-cloudman-12345"
  force_destroy       = false
  object_lock_enabled = false
  tags                              = {
    "Name"         = "s3-cloudman-12345"
    "State"        = "State4"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudman-12345_versioning" {
  bucket = aws_s3_bucket.s3-cloudman-12345.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-cloudman-12345_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.s3-cloudman-12345.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudman-12345_configuration" {
  bucket                = aws_s3_bucket.s3-cloudman-12345.id
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-cloudman-12345_controls" {
  bucket = aws_s3_bucket.s3-cloudman-12345.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}