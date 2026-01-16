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
    key            = "061051249868/State3/main.tfstate"
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

locals {
  api_config_RestAPI1 = [
    {
      path             = "/queue"
      uri              = "arn:aws:apigateway:us-east-1:sqs:path/${data.aws_caller_identity.current.account_id}/Queue"
      type             = "aws"
      methods          = ["delete", "get", "head", "options", "patch", "post", "put"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_Queue.arn}"
      requestTemplates = {
        "application/json" = "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
      }
    },
    {
      path             = "/my-bucket"
      uri              = "arn:aws:apigateway:us-east-1:s3:path/my-bucket"
      type             = "aws"
      methods          = ["delete", "get", "head", "options", "patch", "post", "put"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_my-bucket.arn}"
      requestTemplates = {
        "application/json" = ""
      }
    },
  ]
  openapi_spec_RestAPI1 = {
    openapi = "3.0.1"
    info = {
      title   = "RestAPI1"
      version = "1.0"
    }
    paths = {
      for item in local.api_config_RestAPI1 :
      item.path => merge(
        {
          for method in item.methods :
          method => {
            "x-amazon-apigateway-integration" = merge(
              {
                uri        = item.uri
                httpMethod = "POST"
                type       = item.type
              },
              item.credentials != null ? { credentials = item.credentials } : {},
              item.requestTemplates != null ? { requestTemplates = item.requestTemplates } : {}
            )
          }
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
                  "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'.cloudman.pro'"
                }
              }
            }
          }
        } } : {}
      )
    }
  }
}

resource "aws_api_gateway_rest_api" "RestAPI1" {
  name                              = "RestAPI1"
  body                              = jsonencode(local.openapi_spec_RestAPI1)
  tags                              = {
    "Name" = "RestAPI1"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "Stage1" {
  deployment_id                     = aws_api_gateway_deployment.Deploy.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI1.id
  stage_name                        = "prod"
  cache_cluster_size                = "0.5"
  tags                              = {
    "Name" = "Stage1"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_deployment" "Deploy" {
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI1.id
  lifecycle {
    create_before_destroy           = true
  }
}

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
    "Name" = "Queue"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket" "my-bucket" {
  bucket                            = "my-bucket"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_versioning" "my-bucket_versioning" {
  bucket                            = aws_s3_bucket.my-bucket.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "my-bucket_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket_configuration" {
  bucket                            = aws_s3_bucket.my-bucket.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket_controls" {
  bucket                            = aws_s3_bucket.my-bucket.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "doc_trust_role_apigw_RestAPI1_to_Queue" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = ["apigateway.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_apigw_RestAPI1_to_Queue" {
  name                              = "api-RestAPI1-Queue-role"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_role_apigw_RestAPI1_to_Queue.json
}

data "aws_iam_policy_document" "doc_perm_role_apigw_RestAPI1_to_Queue" {
  statement {
    sid                             = "AllowSQSActions"
    effect                          = "Allow"
    actions                         = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources                       = ["${aws_sqs_queue.Queue.arn}"]
  }
}

resource "aws_iam_role_policy" "policy_role_apigw_RestAPI1_to_Queue" {
  name                              = "access-Queue"
  policy                            = data.aws_iam_policy_document.doc_perm_role_apigw_RestAPI1_to_Queue.json
  role                              = "${aws_iam_role.role_apigw_RestAPI1_to_Queue.id}"
}

data "aws_iam_policy_document" "doc_trust_role_apigw_RestAPI1_to_my-bucket" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = ["apigateway.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_apigw_RestAPI1_to_my-bucket" {
  name                              = "api-RestAPI1-my-bucket-role"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_role_apigw_RestAPI1_to_my-bucket.json
}

data "aws_iam_policy_document" "doc_perm_role_apigw_RestAPI1_to_my-bucket" {
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources                       = ["${aws_s3_bucket.my-bucket.arn}"]
  }
  statement {
    sid                             = "AllowObjectCRUD"
    effect                          = "Allow"
    actions                         = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources                       = ["${aws_s3_bucket.my-bucket.arn}/*"]
  }
}

resource "aws_iam_role_policy" "policy_role_apigw_RestAPI1_to_my-bucket" {
  name                              = "access-my-bucket"
  policy                            = data.aws_iam_policy_document.doc_perm_role_apigw_RestAPI1_to_my-bucket.json
  role                              = "${aws_iam_role.role_apigw_RestAPI1_to_my-bucket.id}"
}