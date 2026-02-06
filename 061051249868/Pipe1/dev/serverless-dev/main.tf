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
    key            = "061051249868/Pipe1/dev/serverless-dev/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### EXTERNAL REFERENCES ###

data "aws_dynamodb_table" "Table-dev" {
  name                              = "Table-dev"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_Function17-dev_st_serverless-dev_doc" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Table-dev.arn}", "${data.aws_dynamodb_table.Table-dev.arn}/*"]
  }
  statement {
    sid                             = "AllowSQSActions"
    effect                          = "Allow"
    actions                         = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources                       = ["${aws_sqs_queue.Queue4-dev.arn}"]
  }
}

resource "aws_iam_policy" "lambda_function_Function17-dev_st_serverless-dev" {
  name                              = "lambda_function_Function17-dev_st_serverless-dev"
  description                       = "Access Policy for Function17-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_Function17-dev_st_serverless-dev_doc.json
}

resource "aws_iam_role" "role_lambda_Function17-dev" {
  name                              = "role_lambda_Function17-dev"
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
    "Name" = "role_lambda_Function17-dev"
    "State" = "serverless-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function17-dev_st_serverless-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function17-dev_st_serverless-dev.arn
  role                              = aws_iam_role.role_lambda_Function17-dev.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function17-dev" {
  output_path                       = "${path.module}/CloudMan_Function17-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function17-dev" {
  function_name                     = "Function17-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function17-dev.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function17-dev.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function17-dev.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_SQS_QUEUE_TARGET_NAME_0" = "Queue4-dev"
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Table-dev"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function17-dev"
    "AWS_SQS_QUEUE_TARGET_ARN_0" = "${aws_sqs_queue.Queue4-dev.arn}"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = "${data.aws_dynamodb_table.Table-dev.arn}"
  }
  }
  tags                              = {
    "Name" = "Function17-dev"
    "State" = "serverless-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Function17-dev_st_serverless-dev_attach]
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "Queue4-dev" {
  name                              = "Queue4-dev"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags                              = {
    "Name" = "Queue4-dev"
    "State" = "serverless-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
}


