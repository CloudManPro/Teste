terraform {
  required_version = ">= 1.0.0"

  required_providers {
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

### EXTERNAL REFERENCES ###

data "aws_iam_role" "role_Function3" {
  name                              = "role_Function3"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "policy_Function3_consolidated_doc" {
  statement {
    sid                             = "AllowSNSPublish"
    effect                          = "Allow"
    actions                         = ["sns:GetDataProtectionPolicy", "sns:GetTopicAttributes", "sns:Publish", "sns:RemovePermission", "sns:SetTopicAttributes"]
    resources                       = ["${aws_sns_topic.Topic.arn}"]
  }
}

resource "aws_iam_policy" "policy_Function3_consolidated" {
  name                              = "policy_Function3_consolidated"
  description                       = "Consolidated Policy for Function3"
  policy                            = data.aws_iam_policy_document.policy_Function3_consolidated_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_Function3_consolidated_attach" {
  policy_arn                        = aws_iam_policy.policy_Function3_consolidated.arn
  role                              = data.aws_iam_role.role_Function3.name
}




### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic" {
  name                              = "Topic"
  content_based_deduplication       = false
  delivery_policy                   = jsonencode([])
  fifo_throughput_scope             = "auto"
  fifo_topic                        = true
  tags                              = {
    "Name" = "Topic"
    "State" = "State6"
    "CloudmanUser" = "GlobalUserName"
  }
}


