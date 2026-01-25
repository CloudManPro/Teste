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
    key            = "952133486861/State117/main.tfstate"
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




### EXTERNAL REFERENCES ###

data "aws_s3_bucket" "my-bucket-1234-teste-xxx-abb" {
  bucket                            = "my-bucket-1234-teste-xxx-abb"
}




### CATEGORY: NETWORK ###

resource "aws_cloudfront_distribution" "CDN1" {
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    origin_request_policy_id        = data.aws_cloudfront_origin_request_policy.policy_cors_s3origin.id
    target_origin_id                = "default_CDN1"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = data.aws_s3_bucket.my-bucket-1234-teste-xxx-abb.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_my-bucket-1234-teste-xxx-abb.id
    origin_id                       = "default_CDN1"
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CDN1"
    "State" = "State117"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    cloudfront_default_certificate  = true
  }
}

resource "aws_cloudfront_origin_access_control" "oac_my-bucket-1234-teste-xxx-abb" {
  name                              = "oac-my-bucket-1234-teste-xxx-abb"
  description                       = "OAC for my-bucket-1234-teste-xxx-abb"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


