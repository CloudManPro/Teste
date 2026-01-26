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
    key            = "061051249868/State24/main.tfstate"
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

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_Instance4" {
  name                              = "profile_Instance4"
  role                              = aws_iam_role.role_Instance4.name
  tags                              = {
    "Name" = "profile_Instance4"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_iam_policy_document" "lambda_function_Function6_st_State24_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources                       = ["${aws_cloudwatch_log_group.LogGroup6.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_Function6_st_State24" {
  name                              = "lambda_function_Function6_st_State24"
  description                       = "Access Policy for Function6 in State24"
  policy                            = data.aws_iam_policy_document.lambda_function_Function6_st_State24_doc.json
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
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Instance4" {
  name                              = "role_Instance4"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_Instance4"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function6_st_State24_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function6_st_State24.arn
  role                              = aws_iam_role.role_Function6.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC5" {
  cidr_block                        = "10.4.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC5"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet6" {
  vpc_id                            = aws_vpc.VPC5.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.4.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet6"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet9" {
  vpc_id                            = aws_vpc.VPC5.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.4.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet9"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW3" {
  vpc_id                            = aws_vpc.VPC5.id
  tags                              = {
    "Name" = "IGW3"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT4_IGW3" {
  gateway_id                        = aws_internet_gateway.IGW3.id
  route_table_id                    = aws_route_table.RT4.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT4" {
  vpc_id                            = aws_vpc.VPC5.id
  tags                              = {
    "Name" = "RT4"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet6_RT4" {
  route_table_id                    = aws_route_table.RT4.id
  subnet_id                         = aws_subnet.Subnet6.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet9_RT4" {
  route_table_id                    = aws_route_table.RT4.id
  subnet_id                         = aws_subnet.Subnet9.id
}

resource "aws_security_group" "ALB2_group" {
  name                              = "ALB2_group"
  vpc_id                            = aws_vpc.VPC5.id
  revoke_rules_on_delete            = false
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
    self                            = false
    to_port                         = 0
  }
  ingress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
    self                            = false
    to_port                         = 0
  }
  tags                              = {
    "Name" = "ALB2_group"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group" "Instance4_group" {
  name                              = "Instance4_group"
  vpc_id                            = aws_vpc.VPC5.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "Instance4_group"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb" "ALB2" {
  name                              = "ALB2"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.ALB2_group.id]
  subnets                           = [aws_subnet.Subnet6.id, aws_subnet.Subnet9.id]
  tags                              = {
    "Name" = "ALB2"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener" "Listener2" {
  load_balancer_arn                 = aws_lb.ALB2.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TargetGroup1.arn
    type                            = "forward"
  }
  tags                              = {
    "Name" = "Listener2"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TargetGroup1" {
  name                              = "TargetGroup1"
  vpc_id                            = aws_vpc.VPC5.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "lambda"
  health_check {
    enabled                         = true
  }
  tags                              = {
    "Name" = "TargetGroup1"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group_attachment" "attach_Function6_to_TargetGroup1" {
  target_id                         = aws_lambda_function.Function6.arn
  target_group_arn                  = aws_lb_target_group.TargetGroup1.arn
  depends_on                        = [aws_lambda_permission.perm_TargetGroup1_to_Function6]
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_Instance4" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance4" {
  subnet_id                         = aws_subnet.Subnet6.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance4.id
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance4.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo "REGION=${data.aws_region.current.name}" > /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=Instance4" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.Instance4_group.id]
  tags                              = {
    "Name" = "Instance4"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function6" {
  output_path                       = "${path.module}/CloudMan_Function6.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function6" {
  function_name                     = "Function6"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function6.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function6.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function6.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_NAME_0" = "LogGroup6"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function6"
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_ARN_0" = "${aws_cloudwatch_log_group.LogGroup6.arn}"
  }
  }
  tags                              = {
    "Name" = "Function6"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lambda_permission" "perm_TargetGroup1_to_Function6" {
  function_name                     = aws_lambda_function.Function6.function_name
  statement_id                      = "perm_TargetGroup1_to_Function6"
  principal                         = "elasticloadbalancing.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_lb_target_group.TargetGroup1.arn
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "LogGroup6" {
  name                              = "/aws/lambda/Function6"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "LogGroup6"
    "State" = "State24"
    "CloudmanUser" = "GlobalUserName"
  }
}


