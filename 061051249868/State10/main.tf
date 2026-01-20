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

### CATEGORY: IAM ###

resource "aws_iam_role" "role_Function10" {
  name                              = "role_Function10"
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
    "Name" = "role_Function10"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function11" {
  name                              = "role_Function11"
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
    "Name" = "role_Function11"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
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
  depends_on                        = [aws_api_gateway_resource.Resource2, aws_api_gateway_integration.Int4, aws_api_gateway_method.Method4]
}

resource "aws_api_gateway_integration" "Int4" {
  resource_id                       = aws_api_gateway_resource.Resource2.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI3.id
  http_method                       = aws_api_gateway_method.Method4.http_method
  integration_http_method           = "POST"
  type                              = "AWS_PROXY"
  uri                               = aws_lambda_function.Function10.invoke_arn
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
      methods          = ["get", "post"]
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/function11"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:Function11/invocations"
      type             = "aws_proxy"
      methods          = ["get", "post"]
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
                  "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
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




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function10" {
  output_path                       = "${path.module}/CloudMan_Function10.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function10" {
  function_name                     = "Function10"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function10.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function10.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function10.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function10"
  }
  }
  tags                              = {
    "Name" = "Function10"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function11" {
  output_path                       = "${path.module}/CloudMan_Function11.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function11" {
  function_name                     = "Function11"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function11.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function11.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function11.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function11"
  }
  }
  tags                              = {
    "Name" = "Function11"
    "State" = "State10"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lambda_permission" "perm_RestAPI3_to_Function10_Method4" {
  function_name                     = aws_lambda_function.Function10.function_name
  statement_id                      = "perm_RestAPI3_to_Function10_Method4"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI3.execution_arn}/*/GET${aws_api_gateway_resource.Resource2.path}"
}

resource "aws_lambda_permission" "perm_RestAPI3_to_Function11_openapi" {
  function_name                     = aws_lambda_function.Function11.function_name
  statement_id                      = "perm_RestAPI3_to_Function11_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI3.execution_arn}/*/*/function11"
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


