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
  ordered_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    origin_request_policy_id        = data.aws_cloudfront_origin_request_policy.policy_cors_s3origin.id
    target_origin_id                = "ordered_Origin"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    path_pattern                    = "/cloudman-cf-test-secondary/*"
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.cloudman-cf-test-main.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_cloudman-cf-test-main.id
    origin_id                       = "default_CDN"
  }
  origin {
    domain_name                     = aws_s3_bucket.cloudman-cf-test-secondary.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_cloudman-cf-test-secondary.id
    origin_id                       = "ordered_Origin"
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

resource "aws_cloudfront_origin_access_control" "oac_cloudman-cf-test-main" {
  name                              = "oac-cloudman-cf-test-main"
  description                       = "OAC for cloudman-cf-test-main"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "oac_cloudman-cf-test-secondary" {
  name                              = "oac-cloudman-cf-test-secondary"
  description                       = "OAC for cloudman-cf-test-secondary"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "cloudman-cf-test-main" {
  bucket                            = "cloudman-cf-test-main"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "cloudman-cf-test-main"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket" "cloudman-cf-test-secondary" {
  bucket                            = "cloudman-cf-test-secondary"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "cloudman-cf-test-secondary"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudman-cf-test-main_controls" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-main.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudman-cf-test-secondary_controls" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-secondary.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_cloudman-cf-test-main_st_State21_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.cloudman-cf-test-main.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_cloudman-cf-test-main_st_State21" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-main.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_cloudman-cf-test-main_st_State21_doc.json
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_cloudman-cf-test-secondary_st_State21_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.cloudman-cf-test-secondary.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_cloudman-cf-test-secondary_st_State21" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-secondary.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_cloudman-cf-test-secondary_st_State21_doc.json
}

resource "aws_s3_bucket_public_access_block" "cloudman-cf-test-main_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.cloudman-cf-test-main.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_public_access_block" "cloudman-cf-test-secondary_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.cloudman-cf-test-secondary.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudman-cf-test-main_configuration" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-main.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudman-cf-test-secondary_configuration" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-secondary.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudman-cf-test-main_versioning" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-main.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "cloudman-cf-test-secondary_versioning" {
  bucket                            = aws_s3_bucket.cloudman-cf-test-secondary.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_object" "Object1" {
  source                            = "${path.module}/.external_modules/CloudMan/HTML/Tretris.html"
  bucket                            = aws_s3_bucket.cloudman-cf-test-main.bucket
  checksum_algorithm                = "CRC32"
  content_language                  = "en-US"
  content_type                      = "text/html"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/HTML/Tretris.html")
  key                               = "index.html"
  tags                              = {
    "Name" = "Object1"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_object" "Object2" {
  source                            = "${path.module}/.external_modules/CloudMan/HTML/Tretris.html"
  bucket                            = aws_s3_bucket.cloudman-cf-test-secondary.bucket
  checksum_algorithm                = "CRC32"
  content_language                  = "en-US"
  content_type                      = "text/html"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/HTML/Tretris.html")
  key                               = "index_html"
  tags                              = {
    "Name" = "Object2"
    "State" = "State21"
    "CloudmanUser" = "GlobalUserName"
  }
}


