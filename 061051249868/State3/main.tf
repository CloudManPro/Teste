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
    path        = "/function2"
    uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:Function2/invocations"
    type        = "aws_proxy"
    methods     = ["delete", "get", "head", "options", "patch", "post", "put"]
    enable_mock = true
  },
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
      item.path = > merge(
      {
        for method in item.methods :
        method => {
          "x-amazon-apigateway-integration" = {
            uri        = item.uri
            httpMethod = "POST"
            type       = item.type
          }
        }
        if method ! = "options"
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
          type             = "mock"
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
  name = "RestAPI1"
  body = jsonencode(local.openapi_spec_RestAPI1)
  tags                              = {
    "Name"         = "RestAPI1"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function2" {
  output_path = "${path.module}/CloudMan_Function2.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type        = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                  = "Function2"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function2.output_path}"
  handler                        = "LambdaHub2.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function2.arn
  runtime                        = "python3.13"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function2.output_base64sha256}"
  timeout                        = 30
  environment {
    variables                       = {
      "REGION"  = "${data.aws_region.current.name}"
      "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
      "NAME"    = "Function2"
    }
  }
  tags                              = {
    "Name"         = "Function2"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "Stage1" {
  deployment_id      = aws_api_gateway_deployment.Deploy.id
  rest_api_id        = aws_api_gateway_rest_api.RestAPI1.id
  stage_name         = "prod"
  cache_cluster_size = "0.5"
  tags                              = {
    "Name"         = "Stage1"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_deployment" "Deploy" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI1.id
  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "archive_CloudMan_Function3" {
  output_path = "${path.module}/CloudMan_Function3.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type        = "zip"
}

resource "aws_lambda_function" "Function3" {
  function_name                  = "Function3"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function3.output_path}"
  handler                        = "LambdaHub2.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function3.arn
  runtime                        = "python3.13"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function3.output_base64sha256}"
  timeout                        = 30
  environment {
    variables                       = {
      "REGION"  = "${data.aws_region.current.name}"
      "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
      "NAME"    = "Function3"
    }
  }
  tags                              = {
    "Name"         = "Function3"
    "State"        = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function2" {
  name = "role_Function2"
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
}

resource "aws_iam_role" "role_Function3" {
  name = "role_Function3"
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
}

resource "aws_lambda_permission" "perm_api_RestAPI1_to_Function2" {
  function_name = aws_lambda_function.Function2.function_name
  statement_id  = "perm_api_RestAPI1_to_Function2"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI1.execution_arn}/*/*"
}

resource "aws_lambda_permission" "perm_api_RestAPI1_to_Function3" {
  function_name = aws_lambda_function.Function3.function_name
  statement_id  = "perm_api_RestAPI1_to_Function3"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI1.execution_arn}/*/*"
}