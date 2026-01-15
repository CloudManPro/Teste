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
    key            = "061051249868/State5/main.tfstate"
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
    "State" = "State5"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lambda_function" "Function2" {
  function_name                     = "Function2"
  architectures                     = ["arm64"]
  filename                          = "teste"
  handler                           = "index.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function2.arn
  runtime                           = "python3.13"
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
    "State" = "State5"
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

data "aws_iam_policy_document" "policy_Function2_st_State5_doc" {
  statement {
    sid                             = "AllowReciveMessage"
    effect                          = "Allow"
    actions                         = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources                       = ["${aws_sqs_queue.Queue.arn}"]
  }
}

resource "aws_iam_policy" "policy_Function2_st_State5" {
  name                              = "policy_Function2_st_State5"
  description                       = "Combined Policy for Function2 in state State5"
  policy                            = data.aws_iam_policy_document.policy_Function2_st_State5_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_Function2_st_State5_attach" {
  policy_arn                        = aws_iam_policy.policy_Function2_st_State5.arn
  role                              = "role_Function2"
}