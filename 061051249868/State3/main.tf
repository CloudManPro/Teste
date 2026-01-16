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
      methods          = ["get", "post", "put", "delete", "head", "options"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_Queue.arn}"
      requestTemplates = {
        "application/json" = "#set($method = $context.httpMethod)#if($method == 'POST' || $method == 'PUT')Action=SendMessage&MessageBody=$util.urlEncode($input.body)#elseif($method == 'GET')Action=ReceiveMessage&MaxNumberOfMessages=10&WaitTimeSeconds=20&VisibilityTimeout=30#elseif($method == 'DELETE')Action=DeleteMessage&ReceiptHandle=$util.urlEncode($input.params('receiptHandle'))#elseif($method == 'HEAD')Action=GetQueueAttributes&AttributeName=ApproximateNumberOfMessages#elseAction=GetQueueAttributes#end"
        "application/x-www-form-urlencoded" = "#set($method = $context.httpMethod)#if($method == 'POST' || $method == 'PUT')Action=SendMessage&MessageBody=$util.urlEncode($input.body)#elseif($method == 'GET')Action=ReceiveMessage&MaxNumberOfMessages=10&WaitTimeSeconds=20&VisibilityTimeout=30#elseif($method == 'DELETE')Action=DeleteMessage&ReceiptHandle=$util.urlEncode($input.params('receiptHandle'))#elseif($method == 'HEAD')Action=GetQueueAttributes&AttributeName=ApproximateNumberOfMessages#elseAction=GetQueueAttributes#end"
        "text/plain" = "#set($method = $context.httpMethod)#if($method == 'POST' || $method == 'PUT')Action=SendMessage&MessageBody=$util.urlEncode($input.body)#elseif($method == 'GET')Action=ReceiveMessage&MaxNumberOfMessages=10&WaitTimeSeconds=20&VisibilityTimeout=30#elseif($method == 'DELETE')Action=DeleteMessage&ReceiptHandle=$util.urlEncode($input.params('receiptHandle'))#elseif($method == 'HEAD')Action=GetQueueAttributes&AttributeName=ApproximateNumberOfMessages#elseAction=GetQueueAttributes#end"
      }
      integ_method     = "POST"
      parameters       = [
          {
            "name": "receiptHandle",
            "in": "query",
            "required": false,
            "schema": { "type": "string" }
          }
        ]
      integ_req_params = {
        "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
      }
    },
    {
      path             = "/my-bucket-aghjklkksjj/{proxy+}"
      uri              = "arn:aws:apigateway:us-east-1:s3:path/my-bucket-aghjklkksjj/{proxy}"
      type             = "aws"
      methods          = ["delete", "get", "head", "options", "patch", "post", "put"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_my-bucket-aghjklkksjj.arn}"
      requestTemplates = null
      integ_method     = "MATCH"
      parameters       = [
          {
            name = "proxy"
            in = "path"
            required = true
            schema = { type = "string" }
          }
        ]
      integ_req_params = {
        "integration.request.path.proxy" = "method.request.path.proxy"
      }
    },
    {
      path             = "/tableopenapi/{Hash}"
      uri              = "arn:aws:apigateway:us-east-1:dynamodb:action/GetItem"
      type             = "aws"
      methods          = ["get"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_TableOpenAPI.arn}"
      requestTemplates = {
        "application/json" = "{\"TableName\": \"TableOpenAPI\", \"Key\": { \"Hash\": { \"S\": \"$util.escapeJavaScript($input.params('Hash'))\" } } }"
      }
      integ_method     = "POST"
      parameters       = [{"name": "Hash", "in": "path", "required": true, "schema": {"type": "string"}}]
      integ_req_params = null
    },
    {
      path             = "/tableopenapi/{Hash}"
      uri              = "arn:aws:apigateway:us-east-1:dynamodb:action/DeleteItem"
      type             = "aws"
      methods          = ["delete"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_TableOpenAPI.arn}"
      requestTemplates = {
        "application/json" = "{\"TableName\": \"TableOpenAPI\", \"Key\": { \"Hash\": { \"S\": \"$util.escapeJavaScript($input.params('Hash'))\" } } }"
      }
      integ_method     = "POST"
      parameters       = [{"name": "Hash", "in": "path", "required": true, "schema": {"type": "string"}}]
      integ_req_params = null
    },
    {
      path             = "/tableopenapi/{Hash}"
      uri              = "arn:aws:apigateway:us-east-1:dynamodb:action/PutItem"
      type             = "aws"
      methods          = ["post", "put"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_TableOpenAPI.arn}"
      requestTemplates = {
        "application/json" = "{\"TableName\": \"TableOpenAPI\", \"Item\": { \"Hash\": { \"S\": \"$util.escapeJavaScript($input.params('Hash'))\" }, \"Payload\": { \"S\": \"$util.escapeJavaScript($input.body)\" } } }"
      }
      integ_method     = "POST"
      parameters       = [{"name": "Hash", "in": "path", "required": true, "schema": {"type": "string"}}]
      integ_req_params = null
    },
    {
      path             = "/tableo2/{ID}/{Sort}"
      uri              = "arn:aws:apigateway:us-east-1:dynamodb:action/GetItem"
      type             = "aws"
      methods          = ["get"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_TableO2.arn}"
      requestTemplates = {
        "application/json" = "{\"TableName\": \"TableO2\", \"Key\": { \"ID\": { \"S\": \"$util.escapeJavaScript($input.params('ID'))\" }, \"Sort\": { \"S\": \"$util.escapeJavaScript($input.params('Sort'))\" } } }"
      }
      integ_method     = "POST"
      parameters       = [{"name": "ID", "in": "path", "required": true, "schema": {"type": "string"}}, {"name": "Sort", "in": "path", "required": true, "schema": {"type": "string"}}]
      integ_req_params = null
    },
    {
      path             = "/tableo2/{ID}/{Sort}"
      uri              = "arn:aws:apigateway:us-east-1:dynamodb:action/DeleteItem"
      type             = "aws"
      methods          = ["delete"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_TableO2.arn}"
      requestTemplates = {
        "application/json" = "{\"TableName\": \"TableO2\", \"Key\": { \"ID\": { \"S\": \"$util.escapeJavaScript($input.params('ID'))\" }, \"Sort\": { \"S\": \"$util.escapeJavaScript($input.params('Sort'))\" } } }"
      }
      integ_method     = "POST"
      parameters       = [{"name": "ID", "in": "path", "required": true, "schema": {"type": "string"}}, {"name": "Sort", "in": "path", "required": true, "schema": {"type": "string"}}]
      integ_req_params = null
    },
    {
      path             = "/tableo2/{ID}/{Sort}"
      uri              = "arn:aws:apigateway:us-east-1:dynamodb:action/PutItem"
      type             = "aws"
      methods          = ["post", "put"]
      enable_mock      = true
      credentials      = "${aws_iam_role.role_apigw_RestAPI1_to_TableO2.arn}"
      requestTemplates = {
        "application/json" = "{\"TableName\": \"TableO2\", \"Item\": { \"ID\": { \"S\": \"$util.escapeJavaScript($input.params('ID'))\" }, \"Sort\": { \"S\": \"$util.escapeJavaScript($input.params('Sort'))\" }, \"Payload\": { \"S\": \"$util.escapeJavaScript($input.body)\" } } }"
      }
      integ_method     = "POST"
      parameters       = [{"name": "ID", "in": "path", "required": true, "schema": {"type": "string"}}, {"name": "Sort", "in": "path", "required": true, "schema": {"type": "string"}}]
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
      for path in distinct([for i in local.api_config_RestAPI1 : i.path]) :
      path => merge([
        for item in local.api_config_RestAPI1 :
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
                  "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT,OPTIONS'"
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

resource "aws_api_gateway_rest_api" "RestAPI1" {
  name                              = "RestAPI1"
  body                              = jsonencode(local.openapi_spec_RestAPI1)
  tags                              = {
    "Name" = "RestAPI1"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
  depends_on                        = [aws_iam_role.role_apigw_RestAPI1_to_TableOpenAPI, aws_iam_role.role_apigw_RestAPI1_to_TableO2, aws_iam_role.role_apigw_RestAPI1_to_my-bucket-aghjklkksjj, aws_iam_role.role_apigw_RestAPI1_to_Queue]
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
  depends_on                        = [aws_api_gateway_integration.Int3, aws_api_gateway_resource.Resource1, aws_api_gateway_method.Method3]
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
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                     = "Function2"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function2.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function2.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function2.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_NAME_0" = "LogGroup1"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function2"
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_ARN_0" = "${aws_cloudwatch_log_group.LogGroup1.arn}"
  }
  }
  tags                              = {
    "Name" = "Function2"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket" "my-bucket-aghjklkksjj" {
  bucket                            = "my-bucket-aghjklkksjj"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket-aghjklkksjj"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_dynamodb_table" "TableOpenAPI" {
  name                              = "TableOpenAPI"
  billing_mode                      = "PROVISIONED"
  deletion_protection_enabled       = false
  hash_key                          = "Hash"
  read_capacity                     = 1
  stream_enabled                    = false
  table_class                       = "STANDARD"
  write_capacity                    = 1
  attribute {
    name                            = "Hash"
    type                            = "S"
  }
  tags                              = {
    "Name" = "TableOpenAPI"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_dynamodb_table" "TableO2" {
  name                              = "TableO2"
  billing_mode                      = "PROVISIONED"
  deletion_protection_enabled       = false
  hash_key                          = "ID"
  range_key                         = "Sort"
  read_capacity                     = 1
  stream_enabled                    = false
  table_class                       = "STANDARD"
  write_capacity                    = 1
  attribute {
    name                            = "ID"
    type                            = "S"
  }
  attribute {
    name                            = "Sort"
    type                            = "S"
  }
  tags                              = {
    "Name" = "TableO2"
    "State" = "State3"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudwatch_log_group" "LogGroup1" {
  name                              = "/aws/lambda/Function2"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "LogGroup1"
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

resource "aws_s3_bucket_versioning" "my-bucket-aghjklkksjj_versioning" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjj.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "my-bucket-aghjklkksjj_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjj.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-aghjklkksjj_configuration" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjj.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-aghjklkksjj_controls" {
  bucket                            = aws_s3_bucket.my-bucket-aghjklkksjj.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "policy_Function2_st_State3_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources                       = ["${aws_cloudwatch_log_group.LogGroup1.arn}:*"]
  }
}

resource "aws_iam_policy" "policy_Function2_st_State3" {
  name                              = "policy_Function2_st_State3"
  description                       = "Combined Policy for Function2 in state State3"
  policy                            = data.aws_iam_policy_document.policy_Function2_st_State3_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_Function2_st_State3_attach" {
  policy_arn                        = aws_iam_policy.policy_Function2_st_State3.arn
  role                              = "role_Function2"
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

data "aws_iam_policy_document" "doc_trust_role_apigw_RestAPI1_to_my-bucket-aghjklkksjj" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = ["apigateway.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_apigw_RestAPI1_to_my-bucket-aghjklkksjj" {
  name                              = "api-RestAPI1-my-bucket-aghjklkksjj-role"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_role_apigw_RestAPI1_to_my-bucket-aghjklkksjj.json
}

data "aws_iam_policy_document" "doc_perm_role_apigw_RestAPI1_to_my-bucket-aghjklkksjj" {
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources                       = ["${aws_s3_bucket.my-bucket-aghjklkksjj.arn}"]
  }
  statement {
    sid                             = "AllowObjectCRUD"
    effect                          = "Allow"
    actions                         = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources                       = ["${aws_s3_bucket.my-bucket-aghjklkksjj.arn}/*"]
  }
}

resource "aws_iam_role_policy" "policy_role_apigw_RestAPI1_to_my-bucket-aghjklkksjj" {
  name                              = "access-my-bucket-aghjklkksjj"
  policy                            = data.aws_iam_policy_document.doc_perm_role_apigw_RestAPI1_to_my-bucket-aghjklkksjj.json
  role                              = "${aws_iam_role.role_apigw_RestAPI1_to_my-bucket-aghjklkksjj.id}"
}

data "aws_iam_policy_document" "doc_trust_role_apigw_RestAPI1_to_TableOpenAPI" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = ["apigateway.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_apigw_RestAPI1_to_TableOpenAPI" {
  name                              = "api-RestAPI1-TableOpenAPI-role"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_role_apigw_RestAPI1_to_TableOpenAPI.json
}

data "aws_iam_policy_document" "doc_perm_role_apigw_RestAPI1_to_TableOpenAPI" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem", "dynamodb:Query"]
    resources                       = ["${aws_dynamodb_table.TableOpenAPI.arn}", "${aws_dynamodb_table.TableOpenAPI.arn}/*"]
  }
}

resource "aws_iam_role_policy" "policy_role_apigw_RestAPI1_to_TableOpenAPI" {
  name                              = "access-TableOpenAPI"
  policy                            = data.aws_iam_policy_document.doc_perm_role_apigw_RestAPI1_to_TableOpenAPI.json
  role                              = "${aws_iam_role.role_apigw_RestAPI1_to_TableOpenAPI.id}"
}

data "aws_iam_policy_document" "doc_trust_role_apigw_RestAPI1_to_TableO2" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = ["apigateway.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_apigw_RestAPI1_to_TableO2" {
  name                              = "api-RestAPI1-TableO2-role"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_role_apigw_RestAPI1_to_TableO2.json
}

data "aws_iam_policy_document" "doc_perm_role_apigw_RestAPI1_to_TableO2" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources                       = ["${aws_dynamodb_table.TableO2.arn}", "${aws_dynamodb_table.TableO2.arn}/*"]
  }
}

resource "aws_iam_role_policy" "policy_role_apigw_RestAPI1_to_TableO2" {
  name                              = "access-TableO2"
  policy                            = data.aws_iam_policy_document.doc_perm_role_apigw_RestAPI1_to_TableO2.json
  role                              = "${aws_iam_role.role_apigw_RestAPI1_to_TableO2.id}"
}

resource "aws_lambda_permission" "perm_Int3_Function2" {
  function_name                     = aws_lambda_function.Function2.function_name
  statement_id                      = "AllowExecutionFromAPIGateway"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI1.execution_arn}/*/${aws_api_gateway_method.Method3.http_method}${aws_api_gateway_resource.Resource1.path}"
}