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
    key            = "952133486861/State34/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "eu-west-3"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: NETWORK ###

resource "aws_api_gateway_deployment" "Deploy3" {
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI4.id
  lifecycle {
    create_before_destroy           = true
  }
}

resource "aws_api_gateway_rest_api" "RestAPI4" {
  name                              = "RestAPI4"
  tags                              = {
    "Name" = "RestAPI4"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "st" {
  deployment_id                     = aws_api_gateway_deployment.Deploy3.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI4.id
  stage_name                        = "st"
  tags                              = {
    "Name" = "st"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudfront_distribution" "CDN4" {
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    target_origin_id                = "default_CDN4"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  ordered_cache_behavior {
    target_origin_id                = "ordered_Origin1"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    path_pattern                    = "/st"
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.my-bucket5.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_my-bucket5.id
    origin_id                       = "default_CDN4"
  }
  origin {
    domain_name                     = "${aws_api_gateway_rest_api.RestAPI4.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
    origin_id                       = "ordered_Origin1"
    custom_origin_config {
      http_port                     = 80
      https_port                    = 443
      origin_protocol_policy        = "https-only"
      origin_ssl_protocols          = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CDN4"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    cloudfront_default_certificate  = true
  }
}

resource "aws_cloudfront_origin_access_control" "oac_my-bucket5" {
  name                              = "oac-my-bucket5"
  description                       = "OAC for my-bucket5"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "my-bucket5" {
  bucket                            = "my-bucket"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket5"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket5_controls" {
  bucket                            = aws_s3_bucket.my-bucket5.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_my-bucket5_st_State34_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.my-bucket5.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN4.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_my-bucket5_st_State34" {
  bucket                            = aws_s3_bucket.my-bucket5.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_my-bucket5_st_State34_doc.json
}

resource "aws_s3_bucket_public_access_block" "my-bucket5_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket5.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket5_configuration" {
  bucket                            = aws_s3_bucket.my-bucket5.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "my-bucket5_versioning" {
  bucket                            = aws_s3_bucket.my-bucket5.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}


