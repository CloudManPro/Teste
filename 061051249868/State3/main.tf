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
      path             = "/queue"
      uri              = "arn:aws:apigateway:us-east-1:sqs:path/${data.aws_caller_identity.current.account_id}/Queue"
      type             = "aws"
      methods          = ["delete", "get", "head", "options", "patch", "post", "put"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_Queue.arn}"
      requestTemplates = {
        "application/json" = "Action=$util.defaultIfEmpty($input.params('Action'), 'SendMessage')&MessageBody=$util.urlEncode($input.body)&ReceiptHandle=$util.defaultIfEmpty($input.params('ReceiptHandle'), '')&MaxNumberOfMessages=$util.defaultIfEmpty($input.params('MaxNumberOfMessages'), '1')&WaitTimeSeconds=$util.defaultIfEmpty($input.params('WaitTimeSeconds'), '0')"
        "application/x-www-form-urlencoded" = "Action=$util.defaultIfEmpty($input.params('Action'), 'SendMessage')&MessageBody=$util.urlEncode($input.body)&ReceiptHandle=$util.defaultIfEmpty($input.params('ReceiptHandle'), '')&MaxNumberOfMessages=$util.defaultIfEmpty($input.params('MaxNumberOfMessages'), '1')&WaitTimeSeconds=$util.defaultIfEmpty($input.params('WaitTimeSeconds'), '0')"
      }
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
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
          method => merge(
            {
              # 1. Method Response: Diz ao cliente que 200 é possível
              "responses" = {
                "200" = {
                  description = "Successful operation"
                }
              }

              # 2. Integration: Configura o mapeamento
              "x-amazon-apigateway-integration" = merge(
                {
                  uri        = item.uri
                  httpMethod = item.integ_method == "MATCH" ? upper(method) : item.integ_method
                  type       = item.type
                  # Mapeamento de Resposta Default (Pega qualquer 2xx do backend e devolve 200)
                  responses  = {
                    "default" = {
                      statusCode = "200"
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
  depends_on                        = [aws_iam_role.role_apigw_RestAPI1_to_Queue]
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
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode([
aws_api_gateway_resource.Resource1.id,
aws_api_gateway_method.Method3.id,
aws_api_gateway_integration.Int3.id
]), jsonencode(aws_api_gateway_rest_api.RestAPI1.body)]))
  }
  depends_on                        = [aws_api_gateway_resource.Resource1, aws_api_gateway_method.Method3, aws_api_gateway_integration.Int3]
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

resource "aws_api_gateway_resource" "Resource1" {
  parent_id                         = aws_api_gateway_rest_api.RestAPI1.root_resource_id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI1.id
  path_part                         = "Resource1"
}

resource "aws_api_gateway_method" "Method3" {
  resource_id                       = aws_api_gateway_resource.Resource1.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI1.id
  authorization                     = "NONE"
  http_method                       = "GET"
}

resource "aws_api_gateway_integration" "Int3" {
  resource_id                       = aws_api_gateway_resource.Resource1.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI1.id
  http_method                       = aws_api_gateway_method.Method3.http_method
  integration_http_method           = "POST"
  type                              = "AWS_PROXY"
  uri                               = aws_lambda_function.Function2.invoke_arn
}

data "archive_file" "archive_CloudMan_Function2" {
  output_path                       = "${path.module}/CloudMan_Function2.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub"
  type                              = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                     = "Function2"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function2.output_path}"
  handler                           = "LambdaHub.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function2.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function2.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function2"
  }
  }
  tags                              = {
    "Name" = "Function2"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function2" {
  name                              = "role_Function2"
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

resource "aws_lambda_permission" "perm_Int3_Function2" {
  function_name                     = aws_lambda_function.Function2.function_name
  statement_id                      = "AllowExecutionFromAPIGateway"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI1.execution_arn}/*/${aws_api_gateway_method.Method3.http_method}${aws_api_gateway_resource.Resource1.path}"
}