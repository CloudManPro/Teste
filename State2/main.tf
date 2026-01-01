terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto nao configurado. Usando estado local.
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["952133486861"]
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_sns_topic" "Topic" {
  name                                     = "Topic"
  application_success_feedback_sample_rate = 0
  fifo_topic                               = false
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  signature_version                        = 0
  sqs_success_feedback_sample_rate         = 0
  tags                              = {
    "Name"         = "Topic"
    "State"        = "State2"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "cldmn_box" "Box" {
}

resource "aws_lambda_function" "Function" {
  function_name                  = "Function"
  architectures                  = ["arm64"]
  filename                       = "teste"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.role_Function.arn
  runtime                        = "python3.13"
  timeout                        = 30
  environment {
    variables                       = {
      "AWS_SNS_TOPIC_TARGET_NAME_0" = "Topic"
      "REGION"                      = "${data.aws_region.current.name}"
      "ACCOUNT"                     = "${data.aws_caller_identity.current.account_id}"
      "NAME"                        = "Function"
      "AWS_SNS_TOPIC_TARGET_ARN_0"  = "${aws_sns_topic.Topic.arn}"
    }
  }
  tags                              = {
    "Name"         = "Function"
    "State"        = "State2"
    "CloudmanUser" = "GlobalUserName"
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

data "aws_iam_policy_document" "policy_Function_st_State2_doc" {
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["${aws_sns_topic.Topic.arn}"]
  }
}

resource "aws_iam_policy" "policy_Function_st_State2" {
  name        = "policy_Function_st_State2"
  description = "Combined Policy for Function in state State2"
  policy      = data.aws_iam_policy_document.policy_Function_st_State2_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_Function_st_State2_attach" {
  policy_arn = aws_iam_policy.policy_Function_st_State2.arn
  role       = "role_Function"
}