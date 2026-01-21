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

  # Backend remoto nao configurado.
}

provider "aws" {
  region = "us-east-1"
}

# Standard Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_Function6_st_State11_doc" {
  statement {
    sid                             = "AllowSNSPublish"
    effect                          = "Allow"
    actions                         = ["sns:Publish"]
    resources                       = ["${aws_sns_topic.Topic2.arn}"]
  }
}

resource "aws_iam_policy" "lambda_function_Function6_st_State11" {
  name                              = "lambda_function_Function6_st_State11"
  description                       = "Access Policy for Function6 in State11"
  policy                            = data.aws_iam_policy_document.lambda_function_Function6_st_State11_doc.json
}

resource "aws_iam_role" "role_Function6" {
  name                              = "role_Function6"
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
    "Name" = "role_Function6"
    "State" = "State11"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function6_st_State11_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function6_st_State11.arn
  role                              = aws_iam_role.role_Function6.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function6" {
  output_path                       = "${path.module}/CloudMan_Function6.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub"
  type                              = "zip"
}

resource "aws_lambda_function" "Function6" {
  function_name                     = "Function6"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function6.output_path}"
  handler                           = "LambdaHub.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function6.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function6.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_SNS_TOPIC_TARGET_NAME_0" = "Topic2"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function6"
    "AWS_SNS_TOPIC_TARGET_ARN_0" = "${aws_sns_topic.Topic2.arn}"
  }
  }
  tags                              = {
    "Name" = "Function6"
    "State" = "State11"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic2" {
  name                              = "Topic2"
  tags                              = {
    "Name" = "Topic2"
    "State" = "State11"
    "CloudmanUser" = "GlobalUserName"
  }
}


