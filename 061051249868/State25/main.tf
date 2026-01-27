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
    key            = "061051249868/State25/main.tfstate"
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

resource "aws_iam_instance_profile" "profile_ASG1" {
  name                              = "profile_ASG1"
  role                              = aws_iam_role.role_ASG1.name
  tags                              = {
    "Name" = "profile_ASG1"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_iam_policy_document" "lambda_function_Function12_st_State25_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources                       = ["${aws_cloudwatch_log_group.LogGroup7.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_Function12_st_State25" {
  name                              = "lambda_function_Function12_st_State25"
  description                       = "Access Policy for Function12 in State25"
  policy                            = data.aws_iam_policy_document.lambda_function_Function12_st_State25_doc.json
}

data "aws_iam_policy_document" "lambda_function_Function13_st_State25_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources                       = ["${aws_cloudwatch_log_group.LogGroup8.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_Function13_st_State25" {
  name                              = "lambda_function_Function13_st_State25"
  description                       = "Access Policy for Function13 in State25"
  policy                            = data.aws_iam_policy_document.lambda_function_Function13_st_State25_doc.json
}

resource "aws_iam_role" "role_ASG1" {
  name                              = "role_ASG1"
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
    "Name" = "role_ASG1"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function12" {
  name                              = "role_Function12"
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
    "Name" = "role_Function12"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function13" {
  name                              = "role_Function13"
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
    "Name" = "role_Function13"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_Function15" {
  name                              = "role_Function15"
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
    "Name" = "role_Function15"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function12_st_State25_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function12_st_State25.arn
  role                              = aws_iam_role.role_Function12.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function13_st_State25_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function13_st_State25.arn
  role                              = aws_iam_role.role_Function13.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC6" {
  cidr_block                        = "10.5.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC6"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet10" {
  vpc_id                            = aws_vpc.VPC6.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.5.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet10"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet15" {
  vpc_id                            = aws_vpc.VPC6.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.5.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet15"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW4" {
  vpc_id                            = aws_vpc.VPC6.id
  tags                              = {
    "Name" = "IGW4"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT6_IGW4" {
  gateway_id                        = aws_internet_gateway.IGW4.id
  route_table_id                    = aws_route_table.RT6.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT6" {
  vpc_id                            = aws_vpc.VPC6.id
  tags                              = {
    "Name" = "RT6"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet10_RT6" {
  route_table_id                    = aws_route_table.RT6.id
  subnet_id                         = aws_subnet.Subnet10.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet15_RT6" {
  route_table_id                    = aws_route_table.RT6.id
  subnet_id                         = aws_subnet.Subnet15.id
}

resource "aws_security_group" "ALB4_group" {
  name                              = "ALB4_group"
  vpc_id                            = aws_vpc.VPC6.id
  revoke_rules_on_delete            = false
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
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
    "Name" = "ALB4_group"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group" "ASG1_group" {
  name                              = "ASG1_group"
  vpc_id                            = aws_vpc.VPC6.id
  revoke_rules_on_delete            = false
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
  tags                              = {
    "Name" = "ASG1_group"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group_rule" "rule_ALB4_group_to_ASG1_group" {
  security_group_id                 = aws_security_group.ASG1_group.id
  source_security_group_id          = aws_security_group.ALB4_group.id
  description                       = "Allow from ALB4_group"
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "ingress"
}

resource "aws_lb" "ALB4" {
  name                              = "ALB4"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.ALB4_group.id]
  subnets                           = [aws_subnet.Subnet10.id, aws_subnet.Subnet15.id]
  tags                              = {
    "Name" = "ALB4"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener" "Listener4" {
  load_balancer_arn                 = aws_lb.ALB4.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG1.arn
    type                            = "forward"
  }
  tags                              = {
    "Name" = "Listener4"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener_rule" "Rule1" {
  action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG4.arn
    type                            = "forward"
  }
  condition {
    query_string {
      key                           = "test"
      value                         = "correto"
    }
  }
  condition {
    path_pattern {
      values                        = ["/test*", "/lambda*"]
    }
  }
  listener_arn                      = aws_lb_listener.Listener4.arn
  priority                          = 1
  tags                              = {
    "Name" = "Rule1"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener_rule" "Rule2" {
  action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG2.arn
    type                            = "forward"
  }
  condition {
    path_pattern {
      values                        = ["/test*"]
    }
  }
  listener_arn                      = aws_lb_listener.Listener4.arn
  priority                          = 2
  tags                              = {
    "Name" = "Rule2"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener_rule" "Rule3" {
  action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG5.arn
    type                            = "forward"
  }
  condition {
    path_pattern {
      values                        = ["/ec2*"]
    }
  }
  listener_arn                      = aws_lb_listener.Listener4.arn
  priority                          = 3
  tags                              = {
    "Name" = "Rule3"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TG1" {
  name                              = "TG1"
  vpc_id                            = aws_vpc.VPC6.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "lambda"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200"
    path                            = "/"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
  tags                              = {
    "Name" = "TG1"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TG2" {
  name                              = "TG2"
  vpc_id                            = aws_vpc.VPC6.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "lambda"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200"
    path                            = "/"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
  tags                              = {
    "Name" = "TG2"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TG4" {
  name                              = "TG4"
  vpc_id                            = aws_vpc.VPC6.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "lambda"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200"
    path                            = "/"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
  tags                              = {
    "Name" = "TG4"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TG5" {
  name                              = "TG5"
  vpc_id                            = aws_vpc.VPC6.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "instance"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200"
    path                            = "/"
    port                            = 80
    protocol                        = "HTTP"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
  tags                              = {
    "Name" = "TG5"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group_attachment" "attach_Function12_to_TG1" {
  target_id                         = aws_lambda_function.Function12.arn
  target_group_arn                  = aws_lb_target_group.TG1.arn
  depends_on                        = [aws_lambda_permission.perm_TG1_to_Function12]
}

resource "aws_lb_target_group_attachment" "attach_Function13_to_TG2" {
  target_id                         = aws_lambda_function.Function13.arn
  target_group_arn                  = aws_lb_target_group.TG2.arn
  depends_on                        = [aws_lambda_permission.perm_TG2_to_Function13]
}

resource "aws_lb_target_group_attachment" "attach_Function15_to_TG4" {
  target_id                         = aws_lambda_function.Function15.arn
  target_group_arn                  = aws_lb_target_group.TG4.arn
  depends_on                        = [aws_lambda_permission.perm_TG4_to_Function15]
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_Template1" {
  filename                          = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Template1" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Template1" {
  image_id                          = data.aws_ami.AMI_Data_Source_Template1.id
  name                              = "Template1"
  ebs_optimized                     = true
  instance_type                     = "t3.micro"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Template1.content}
EOFUData
)
  vpc_security_group_ids            = [aws_security_group.ASG1_group.id]
  iam_instance_profile {
    name                            = aws_iam_instance_profile.profile_ASG1.name
  }
  tags                              = {
    "Name" = "Template1"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_autoscaling_group" "ASG1" {
  name                              = "ASG1"
  capacity_rebalance                = false
  default_cooldown                  = 300
  default_instance_warmup           = 0
  desired_capacity                  = 2
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_grace_period         = 300
  health_check_type                 = "EC2"
  ignore_failed_scaling_activities  = false
  max_instance_lifetime             = 0
  max_size                          = 2
  min_elb_capacity                  = 0
  min_size                          = 2
  protect_from_scale_in             = false
  target_group_arns                 = [aws_lb_target_group.TG5.arn]
  termination_policies              = ["Default"]
  vpc_zone_identifier               = [aws_subnet.Subnet10.id, aws_subnet.Subnet15.id]
  wait_for_elb_capacity             = 0
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template1.id
  }
  tag {
    key                             = "Name"
    propagate_at_launch             = true
    value                           = "ASG1"
  }
  tag {
    key                             = "State"
    propagate_at_launch             = true
    value                           = "State25"
  }
  tag {
    key                             = "CloudmanUser"
    propagate_at_launch             = true
    value                           = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function12" {
  output_path                       = "${path.module}/CloudMan_Function12.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function12" {
  function_name                     = "Function12"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function12.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function12.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function12.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_NAME_0" = "LogGroup7"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function12"
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_ARN_0" = "${aws_cloudwatch_log_group.LogGroup7.arn}"
  }
  }
  tags                              = {
    "Name" = "Function12"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function13" {
  output_path                       = "${path.module}/CloudMan_Function13.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function13" {
  function_name                     = "Function13"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function13.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function13.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function13.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_NAME_0" = "LogGroup8"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function13"
    "AWS_CLOUDWATCH_LOG_GROUP_TARGET_ARN_0" = "${aws_cloudwatch_log_group.LogGroup8.arn}"
  }
  }
  tags                              = {
    "Name" = "Function13"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "archive_file" "archive_CloudMan_Function15" {
  output_path                       = "${path.module}/CloudMan_Function15.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function15" {
  function_name                     = "Function15"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function15.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_Function15.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function15.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
    "NAME" = "Function15"
  }
  }
  tags                              = {
    "Name" = "Function15"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lambda_permission" "perm_TG1_to_Function12" {
  function_name                     = aws_lambda_function.Function12.function_name
  statement_id                      = "perm_TG1_to_Function12"
  principal                         = "elasticloadbalancing.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_lb_target_group.TG1.arn
}

resource "aws_lambda_permission" "perm_TG2_to_Function13" {
  function_name                     = aws_lambda_function.Function13.function_name
  statement_id                      = "perm_TG2_to_Function13"
  principal                         = "elasticloadbalancing.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_lb_target_group.TG2.arn
}

resource "aws_lambda_permission" "perm_TG4_to_Function15" {
  function_name                     = aws_lambda_function.Function15.function_name
  statement_id                      = "perm_TG4_to_Function15"
  principal                         = "elasticloadbalancing.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_lb_target_group.TG4.arn
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "LogGroup7" {
  name                              = "/aws/lambda/Function12"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "LogGroup7"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudwatch_log_group" "LogGroup8" {
  name                              = "/aws/lambda/Function13"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "LogGroup8"
    "State" = "State25"
    "CloudmanUser" = "GlobalUserName"
  }
}


