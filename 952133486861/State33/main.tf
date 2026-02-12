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
    key            = "952133486861/State33/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "eu-west-3"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: MISC ###

resource "aws_cognito_user_pool" "Cog1" {
  name                              = "Cog1"
  auto_verified_attributes          = ["email"]
  deletion_protection               = "INACTIVE"
  mfa_configuration                 = "OFF"
  password_policy {
    minimum_length                  = 8
    require_lowercase               = true
    require_numbers                 = true
    require_symbols                 = true
    require_uppercase               = true
    temporary_password_validity_days = 7
  }
  schema {
    name                            = "stage"
    attribute_data_type             = "String"
    developer_only_attribute        = false
    mutable                         = true
    required                        = false
    string_attribute_constraints {
      max_length                    = "20"
      min_length                    = "2"
    }
  }
  sign_in_policy {
    allowed_first_auth_factors      = ["PASSWORD"]
  }
  tags                              = {
    "Name" = "Cog1"
    "State" = "State33"
    "CloudmanUser" = "GlobalUserName"
  }
  username_configuration {
    case_sensitive                  = true
  }
  verification_message_template {
    default_email_option            = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_client" "Cog1" {
  name                              = "Cog1"
  user_pool_id                      = aws_cognito_user_pool.Cog1.id
  access_token_validity             = 12
  allowed_oauth_flows               = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes              = ["openid", "email", "profile"]
  auth_session_validity             = 3
  callback_urls                     = ["https://cloudman.pro"]
  enable_propagate_additional_user_context_data = false
  enable_token_revocation           = true
  explicit_auth_flows               = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  generate_secret                   = true
  id_token_validity                 = 12
  prevent_user_existence_errors     = "ENABLED"
  refresh_token_validity            = 12
  supported_identity_providers      = ["COGNITO"]
  token_validity_units {
    access_token                    = "hours"
    id_token                        = "hours"
    refresh_token                   = "hours"
  }
}


