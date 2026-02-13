terraform {
  required_version = ">= 1.0.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.2"
    }
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

### SYSTEM DATA SOURCES ###

data "aws_cloudfront_origin_request_policy" "policy_cors_s3origin" {
  name                              = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "policy_cors_and_securityheaderspolicy" {
  name                              = "Managed-CORS-and-SecurityHeadersPolicy"
}

data "aws_cloudfront_cache_policy" "policy_cachingdisabled" {
  name                              = "Managed-CachingDisabled"
}

data "aws_cloudfront_response_headers_policy" "policy_securityheaderspolicy" {
  name                              = "Managed-SecurityHeadersPolicy"
}




### CATEGORY: IAM ###

resource "aws_iam_role" "role_lambda_Function20" {
  name                              = "role_lambda_Function20"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_lambda_Function20"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: NETWORK ###

resource "aws_api_gateway_deployment" "Deploy3" {
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI4.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.RestAPI4.body)]))
  }
}

locals {
  api_config_RestAPI4 = [
    {
      path             = "/function20"
      uri              = "arn:aws:apigateway:eu-west-3:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-3:${data.aws_caller_identity.current.account_id}:function:Function20/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]
  openapi_spec_RestAPI4 = {
    openapi = "3.0.1"
    info = {
      title   = "RestAPI4"
      version = "1.0"
    }
    paths = {
      for path in distinct([for i in local.api_config_RestAPI4 : i.path]) :
      path => merge([
        for item in local.api_config_RestAPI4 :
        merge(
          {
            for method in item.methods :
            method => merge(
              {
                "responses" = {
                  "200" = {
                    description = "Successful operation"
                    headers = {
                      "Access-Control-Allow-Origin" = { type = "string" }
                    }
                  }
                }
                "x-amazon-apigateway-integration" = merge(
                  {
                    uri        = item.uri
                    httpMethod = item.integ_method == "MATCH" ? upper(method) : item.integ_method
                    type       = item.type
                    responses  = {
                      "default" = {
                        statusCode = "200"
                        responseParameters = {
                          "method.response.header.Access-Control-Allow-Origin" = "'*'"
                        }
                        responseTemplates = {
                          "application/json" = "$input.body"
                          "application/xml"  = "$input.body"
                          "text/plain"       = "$input.body"
                        }
                      }
                    }
                  },
                  item.credentials != null ? { credentials = item.credentials } : {},
                  item.requestTemplates != null ? { requestTemplates = item.requestTemplates } : {},
                  item.integ_req_params != null ? { requestParameters = item.integ_req_params } : {}
                )
              },
              item.parameters != null ? { parameters = item.parameters } : {}
            )
            if method != "options"
          },
          item.enable_mock ? { "options" = {
          summary  = "CORS support"
          consumes = ["application/json"]
          produces = ["application/json"]
          responses = {
            "200" = {
              description = "200 response"
              headers = {
                "Access-Control-Allow-Origin"  = { type = "string" }
                "Access-Control-Allow-Methods" = { type = "string" }
                "Access-Control-Allow-Headers" = { type = "string" }
              }
            }
          }
          "x-amazon-apigateway-integration" = {
            type = "mock"
            requestTemplates = { "application/json" = "{\"statusCode\": 200}" }
            responses = {
              default = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
              }
            }
          }
        } } : {}
        )
        if item.path == path
      ]...)
    }
  }
}

resource "aws_api_gateway_rest_api" "RestAPI4" {
  name                              = "RestAPI4"
  body                              = jsonencode(local.openapi_spec_RestAPI4)
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
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    origin_request_policy_id        = data.aws_cloudfront_origin_request_policy.policy_cors_s3origin.id
    response_headers_policy_id      = data.aws_cloudfront_response_headers_policy.policy_cors_and_securityheaderspolicy.id
    target_origin_id                = "default_CDN4"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  ordered_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingdisabled.id
    response_headers_policy_id      = data.aws_cloudfront_response_headers_policy.policy_securityheaderspolicy.id
    target_origin_id                = "ordered_Origin1"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    path_pattern                    = "/st"
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.my-bucket-aghjklkksjjaaam.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_my-bucket-aghjklkksjjaaam.id
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

resource "aws_cloudfront_origin_access_control" "oac_my-bucket-aghjklkksjjaaam" {
  name                              = "oac-my-bucket-aghjklkksjjaaam"
  description                       = "OAC for my-bucket-aghjklkksjjaaam"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "my-bucket-aghjklkksjjaaam" {
  bucket                            = "my-bucket-aghjklkksjjaaam"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket-aghjklkksjjaaam"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-aghjklkksjjaaam_controls" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjjaaam.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_my-bucket-aghjklkksjjaaam_st_State34_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.my-bucket-aghjklkksjjaaam.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN4.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_my-bucket-aghjklkksjjaaam_st_State34" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjjaaam.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_my-bucket-aghjklkksjjaaam_st_State34_doc.json
}

resource "aws_s3_bucket_public_access_block" "my-bucket-aghjklkksjjaaam_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjjaaam.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-aghjklkksjjaaam_configuration" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjjaaam.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "my-bucket-aghjklkksjjaaam_versioning" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjjaaam.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_Function20" {
  output_path                       = "${path.module}/CloudManMainV2_Function20.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function20" {
  function_name                     = "Function20"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_Function20.output_path}"
  handler                           = "index.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function20.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_Function20.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function20"
  }
  }
  tags                              = {
    "Name" = "Function20"
    "State" = "State34"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lambda_permission" "perm_RestAPI4_to_Function20_openapi" {
  function_name                     = aws_lambda_function.Function20.function_name
  statement_id                      = "perm_RestAPI4_to_Function20_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI4.execution_arn}/*/POST/function20"
}


