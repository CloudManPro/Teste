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
      path        = "/function3"
      uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:Function3/invocations"
      type        = "aws_proxy"
      methods     = ["delete", "get", "head", "options", "patch", "post", "put"]
      enable_mock = true
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
            "x-amazon-apigateway-integration" = {
              uri        = item.uri
              httpMethod = "POST"
              type       = item.type
            }
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
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
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