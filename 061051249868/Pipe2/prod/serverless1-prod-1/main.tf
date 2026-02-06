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
    key            = "061051249868/Pipe2/prod/serverless1-prod-1/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### EXTERNAL REFERENCES ###

data "aws_dynamodb_table" "Table1-1" {
  name                              = "Table1-1"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_Function18-prod-1_st_serverless1-prod-1_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.LogGroup9-prod-1.arn}:*"]
  }
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Table1-1.arn}", "${data.aws_dynamodb_table.Table1-1.arn}/*"]
  }
  statement {
    sid                             = "AllowSQSActions"
    effect                          = "Allow"
    actions                         = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources                       = ["${aws_sqs_queue.Queue5-prod-1.arn}"]
  }
}

resource "aws_iam_policy" "lambda_function_Function18-prod-1_st_serverless1-prod-1" {
  name                              = "lambda_function_Function18-prod-1_st_serverless1-prod-1"
  description                       = "Access Policy for Function18-prod-1"
  policy                            = data.aws_iam_policy_document.lambda_function_Function18-prod-1_st_serverless1-prod-1_doc.json
}

resource "aws_iam_role" "role_lambda_Function18-prod-1" {
  name                              = "role_lambda_Function18-prod-1"
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
    "Name" = "role_lambda_Function18-prod-1"
    "State" = "serverless1-prod-1"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function18-prod-1_st_serverless1-prod-1_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function18-prod-1_st_serverless1-prod-1.arn
  role                              = aws_iam_role.role_lambda_Function18-prod-1.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function18-prod-1" {
  output_path                       = "${path.module}/CloudMan_Function18-prod-1.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function18-prod-1" {
  function_name                     = "Function18-prod-1"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function18-prod-1.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function18-prod-1.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function18-prod-1.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_SQS_QUEUE_TARGET_NAME_0" = "Queue5-prod-1"
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Table1-1"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function18-prod-1"
    "AWS_SQS_QUEUE_TARGET_ARN_0" = "${aws_sqs_queue.Queue5-prod-1.arn}"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = "${data.aws_dynamodb_table.Table1-1.arn}"
  }
  }
  tags                              = {
    "Name" = "Function18-prod-1"
    "State" = "serverless1-prod-1"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Function18-prod-1_st_serverless1-prod-1_attach]
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "Queue5-prod-1" {
  name                              = "Queue5-prod-1"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags                              = {
    "Name" = "Queue5-prod-1"
    "State" = "serverless1-prod-1"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "LogGroup9-prod-1" {
  name                              = "/aws/lambda/Function18-prod-1"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "LogGroup9-prod-1"
    "State" = "serverless1-prod-1"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}


