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

### SYSTEM DATA SOURCES ###

data "aws_cloudfront_origin_request_policy" "policy_cors_s3origin" {
  name                              = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "my-bucket-1234-teste-xxx-abb" {
  bucket                            = "my-bucket-1234-teste-xxx-abb"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket-1234-teste-xxx-abb"
    "State" = "State116"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-1234-teste-xxx-abb_controls" {
  bucket                            = aws_s3_bucket.my-bucket-1234-teste-xxx-abb.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_my-bucket-1234-teste-xxx-abb_st_State116_doc" {
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    effect    = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.my-bucket-1234-teste-xxx-abb.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount" # MUDANÇA AQUI
      values   = [data.aws_caller_identity.current.account_id] # ID DA SUA CONTA
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_my-bucket-1234-teste-xxx-abb_st_State116" {
  bucket                            = aws_s3_bucket.my-bucket-1234-teste-xxx-abb.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_my-bucket-1234-teste-xxx-abb_st_State116_doc.json
}

resource "aws_s3_bucket_public_access_block" "my-bucket-1234-teste-xxx-abb_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket-1234-teste-xxx-abb.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-1234-teste-xxx-abb_configuration" {
  bucket                            = aws_s3_bucket.my-bucket-1234-teste-xxx-abb.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "my-bucket-1234-teste-xxx-abb_versioning" {
  bucket                            = aws_s3_bucket.my-bucket-1234-teste-xxx-abb.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_object" "index_html1" {
  source                            = "${path.module}/.external_modules/CloudMan/HTML/Tretris.html"
  bucket                            = aws_s3_bucket.my-bucket-1234-teste-xxx-abb.bucket
  checksum_algorithm                = "CRC32"
  content_language                  = "en-US"
  content_type                      = "text/html"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/HTML/Tretris.html")
  key                               = "index.html"
  tags                              = {
    "Name" = "index_html1"
    "State" = "State116"
    "CloudmanUser" = "GlobalUserName"
  }
}


