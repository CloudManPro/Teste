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
    key            = "952133486861/State21/main.tfstate"
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

data "aws_route53_zone" "Cloudman" {
  name                              = "cloudman.pro"
}

data "aws_cloudfront_origin_request_policy" "policy_cors_s3origin" {
  name                              = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}




### CATEGORY: IAM ###

resource "aws_acm_certificate" "Certificate" {
  domain_name                       = "testecf.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  tags                              = {
    "Name" = "Certificate"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate" {
  certificate_arn                   = aws_acm_certificate.Certificate.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_Certificate" {
  for_each                          = {for dvo in aws_acm_certificate.Certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}

resource "aws_route53_record" "alias_a_testecf_to_CDN" {
  name                              = "testecf.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.CDN.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_testecf_to_CDN" {
  name                              = "testecf.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.CDN.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_cloudfront_distribution" "CDN" {
  aliases                           = ["testecf.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    origin_request_policy_id        = data.aws_cloudfront_origin_request_policy.policy_cors_s3origin.id
    target_origin_id                = "default_CDN"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.my-bucket-cf-test1234.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_my-bucket-cf-test1234.id
    origin_id                       = "default_CDN"
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CDN"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.Certificate.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_my-bucket-cf-test1234" {
  name                              = "oac-my-bucket-cf-test1234"
  description                       = "OAC for my-bucket-cf-test1234"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "my-bucket-cf-test1234" {
  bucket                            = "my-bucket-cf-test1234"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket-cf-test1234"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-cf-test1234_controls" {
  bucket                            = aws_s3_bucket.my-bucket-cf-test1234.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_my-bucket-cf-test1234_st_State21_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.my-bucket-cf-test1234.arn}/*"]
    condition                       = {
    "StringEquals" = {
    "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN.id}"
  }
  }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_my-bucket-cf-test1234_st_State21" {
  bucket                            = aws_s3_bucket.my-bucket-cf-test1234.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_my-bucket-cf-test1234_st_State21_doc.json
}

resource "aws_s3_bucket_public_access_block" "my-bucket-cf-test1234_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket-cf-test1234.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-cf-test1234_configuration" {
  bucket                            = aws_s3_bucket.my-bucket-cf-test1234.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "my-bucket-cf-test1234_versioning" {
  bucket                            = aws_s3_bucket.my-bucket-cf-test1234.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_object" "index_html" {
  source                            = "${path.module}/.external_modules//HTML/Tretris.html"
  bucket                            = aws_s3_bucket.my-bucket-cf-test1234.bucket
  checksum_algorithm                = "CRC32"
  content_type                      = "application/octet-stream"
  etag                              = filemd5("${path.module}/.external_modules//HTML/Tretris.html")
  key                               = "index.html"
  tags                              = {
    "Name" = "index_html"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}


