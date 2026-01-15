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
  openapi_spec_RestAPI1 = {
    "openapi" = "3.0.1"
    "info" = {
      "title"   = "RestAPI1"
      "version" = "1.0"
    }
    "paths" = {
      "/function2" = {
        "delete" = {
          "x-amazon-apigateway-integration" = {
            "uri"        = "${aws_lambda_function.Function2.invoke_arn}"
            "httpMethod" = "POST"
            "type"       = "aws_proxy"
          }
        }
        "get" = {
          "x-amazon-apigateway-integration" = {
            "uri"        = "${aws_lambda_function.Function2.invoke_arn}"
            "httpMethod" = "POST"
            "type"       = "aws_proxy"
          }
        }
        "head" = {
          "x-amazon-apigateway-integration" = {
            "uri"        = "${aws_lambda_function.Function2.invoke_arn}"
            "httpMethod" = "POST"
            "type"       = "aws_proxy"
          }
        }
        "patch" = {
          "x-amazon-apigateway-integration" = {
            "uri"        = "${aws_lambda_function.Function2.invoke_arn}"
            "httpMethod" = "POST"
            "type"       = "aws_proxy"
          }
        }
        "post" = {
          "x-amazon-apigateway-integration" = {
            "uri"        = "${aws_lambda_function.Function2.invoke_arn}"
            "httpMethod" = "POST"
            "type"       = "aws_proxy"
          }
        }
        "put" = {
          "x-amazon-apigateway-integration" = {
            "uri"        = "${aws_lambda_function.Function2.invoke_arn}"
            "httpMethod" = "POST"
            "type"       = "aws_proxy"
          }
        }
        "options" = {
          "summary"  = "CORS support"
          "consumes" = ["application/json"]
          "produces" = ["application/json"]
          "responses" = {
            "200" = {
              "description" = "200 response"
              "headers" = {
                "Access-Control-Allow-Origin" = {
                  "type" = "string"
                }
                "Access-Control-Allow-Methods" = {
                  "type" = "string"
                }
                "Access-Control-Allow-Headers" = {
                  "type" = "string"
                }
              }
            }
          }
          "x-amazon-apigateway-integration" = {
            "type" = "mock"
            "requestTemplates" = {
              "application/json" = "{\"statusCode\": 200}"
            }
            "responses" = {
              "default" = {
                "statusCode" = "200"
                "responseParameters" = {
                  "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
              }
            }
          }
        }
      }
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
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub"
  type        = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                  = "Function2"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function2.output_path}"
  handler                        = "LambdaHub.lambda_handler"
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

resource "aws_lambda_permission" "perm_api_RestAPI1_to_Function2" {
  function_name = aws_lambda_function.Function2.function_name
  statement_id  = "perm_api_RestAPI1_to_Function2"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI1.execution_arn}/*/*"
}