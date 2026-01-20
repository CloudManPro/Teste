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
    key            = "061051249868/State10/main.tfstate"
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

### EXTERNAL REFERENCES ###

data "aws_lambda_function" "Function9" {
  name                              = "Function9"
}




### CATEGORY: NETWORK ###

resource "aws_api_gateway_deployment" "Deploy2" {
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI3.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode([
aws_api_gateway_resource.Resource2.id,
aws_api_gateway_method.Method4.id,
aws_api_gateway_integration.Int4.id
]), jsonencode(aws_api_gateway_rest_api.RestAPI3.body)]))
  }
  depends_on                        = [aws_api_gateway_method.Method4, aws_api_gateway_integration.Int4, aws_api_gateway_resource.Resource2]
}

resource "aws_api_gateway_integration" "Int4" {
  resource_id                       = aws_api_gateway_resource.Resource2.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI3.id
  http_method                       = aws_api_gateway_method.Method4.http_method
  integration_http_method           = "POST"
  type                              = "AWS_PROXY"
  uri                               = data.aws_lambda_function.Function9.invoke_arn
}

resource "aws_api_gateway_method" "Method4" {
  resource_id                       = aws_api_gateway_resource.Resource2.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI3.id
  authorization                     = "NONE"
  http_method                       = "GET"
}

resource "aws_api_gateway_resource" "Resource2" {
  parent_id                         = aws_api_gateway_rest_api.RestAPI3.root_resource_id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI3.id
  path_part                         = "Resource2"
}

locals {
  api_config_RestAPI3 = [
    {
      path             = "/function5"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:Function5/invocations"
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
  openapi_spec_RestAPI3 = {
    openapi = "3.0.1"
    info = {
      title   = "RestAPI3"
      version = "1.0"
    }
    paths = {
      for path in distinct([for i in local.api_config_RestAPI3 : i.path]) :
      path => merge([
        for item in local.api_config_RestAPI3 :
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

resource "aws_api_gateway_rest_api" "RestAPI3" {
  name                              = "RestAPI3"
  body                              = jsonencode(local.openapi_spec_RestAPI3)
  tags                              = {
    "Name" = "RestAPI3"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "Stage3" {
  deployment_id                     = aws_api_gateway_deployment.Deploy2.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI3.id
  stage_name                        = "prod"
  cache_cluster_size                = "0.5"
  tags                              = {
    "Name" = "Stage3"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "LogGroup5" {
  name                              = "/aws/apigateway/Stage3"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "LogGroup5"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
}


