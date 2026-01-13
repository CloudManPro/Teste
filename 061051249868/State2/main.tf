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
    key            = "061051249868/State2/main.tfstate"
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
resource "aws_api_gateway_rest_api" "RestAPI" {
  name        = "RestAPI"
  description = "Minha API"
  tags                              = {
    "Name"         = "RestAPI"
    "State"        = "State2"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_resource" "Resource" {
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  path_part   = "Resource"
}

resource "aws_api_gateway_integration" "AWS" {
  resource_id             = aws_api_gateway_resource.Resource.id
  rest_api_id             = aws_api_gateway_rest_api.RestAPI.id
  content_handling        = "CONVERT_TO_BINARY"
  http_method             = aws_api_gateway_method.Method1.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  type                    = "AWS"
  uri                     = aws_lambda_function.Function.invoke_arn
  request_templates                 = {
    "application/json" = <<EOF
{
  "body" : $input.json('$'),
  "headers": {
    #foreach($param in $input.params().header.keySet())
    "$param": "$util.escapeJavaScript($input.params().header.get($param))" #if($foreach.hasNext),#end
    #end
  },
  "queryParams": {
    #foreach($param in $input.params().querystring.keySet())
    "$param": "$util.escapeJavaScript($input.params().querystring.get($param))" #if($foreach.hasNext),#end
    #end
  },
  "pathParams": {
    #foreach($param in $input.params().path.keySet())
    "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end
    #end
  }
}
EOF
  }
}

data "archive_file" "archive_CloudMan_Function" {
  output_path = "${path.module}/CloudMan_Function.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub"
  type        = "zip"
}

resource "aws_lambda_function" "Function" {
  function_name                  = "Function"
  architectures                  = ["arm64"]
  filename                       = "${data.archive_file.archive_CloudMan_Function.output_path}"
  handler                        = "LambdaHub.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function.arn
  runtime                        = "python3.13"
  source_code_hash               = "${data.archive_file.archive_CloudMan_Function.output_base64sha256}"
  timeout                        = 30
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
  tags                              = {
    "Name"         = "Function"
    "State"        = "State2"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "Stage" {
  deployment_id      = aws_api_gateway_deployment.Deploy1.id
  rest_api_id        = aws_api_gateway_rest_api.RestAPI.id
  stage_name         = "prod"
  cache_cluster_size = "0.5"
  tags                              = {
    "Name"         = "Stage"
    "State"        = "State2"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_method" "Method1" {
  resource_id   = aws_api_gateway_resource.Resource.id
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  authorization = "NONE"
  http_method   = "GET"
}

resource "aws_api_gateway_method_response" "MResp" {
  resource_id = aws_api_gateway_resource.Resource.id
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  http_method = aws_api_gateway_method.Method1.http_method
  status_code = "200"
  response_models                   = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "IntResp" {
  resource_id      = aws_api_gateway_resource.Resource.id
  rest_api_id      = aws_api_gateway_rest_api.RestAPI.id
  content_handling = "CONVERT_TO_BINARY"
  http_method      = aws_api_gateway_method.Method1.http_method
  status_code      = "200"
  response_templates                = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.AWS]
}

resource "aws_api_gateway_deployment" "Deploy1" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  lifecycle {
    create_before_destroy = true
  }
  triggers                          = {
    "redeployment" = sha1(jsonencode([
    aws_api_gateway_resource.Resource.id,
    aws_api_gateway_method.Method1.id,
    aws_api_gateway_method.Method2.id,
    aws_api_gateway_integration.AWS.id,
    aws_api_gateway_integration.MOCK.id,
    aws_api_gateway_integration_response.IntResp.id,
    aws_api_gateway_method_response.MResp.id
    ]))
  }
  depends_on = [aws_api_gateway_method_response.MResp, aws_api_gateway_resource.Resource, aws_api_gateway_integration.MOCK, aws_api_gateway_method.Method1, aws_api_gateway_integration_response.IntResp, aws_api_gateway_method.Method2, aws_api_gateway_integration.AWS]
}

resource "aws_api_gateway_method" "Method2" {
  resource_id   = aws_api_gateway_resource.Resource.id
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  authorization = "NONE"
  http_method   = "OPTIONS"
}

resource "aws_api_gateway_integration" "MOCK" {
  resource_id             = aws_api_gateway_resource.Resource.id
  rest_api_id             = aws_api_gateway_rest_api.RestAPI.id
  http_method             = aws_api_gateway_method.Method2.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  type                    = "MOCK"
  request_templates                 = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_iam_role" "role_Function" {
  name = "role_Function"
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

resource "aws_lambda_permission" "perm_AWS_Function" {
  function_name = aws_lambda_function.Function.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/${aws_api_gateway_method.Method1.http_method}${aws_api_gateway_resource.Resource.path}"
}