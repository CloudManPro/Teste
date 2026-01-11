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
    key            = "061051249868/State1/main.tfstate"
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
resource "aws_vpc" "VPC2" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
  tags                              = {
    "Name"         = "VPC2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_subnet" "Subnet3" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1d"
  cidr_block              = "10.2.3.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet3"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_autoscaling_group" "ASG" {
  name                             = "ASG"
  capacity_rebalance               = true
  default_cooldown                 = 300
  default_instance_warmup          = 0
  desired_capacity                 = 1
  desired_capacity_type            = "units"
  force_delete                     = false
  force_delete_warm_pool           = false
  health_check_grace_period        = 300
  health_check_type                = "EC2"
  ignore_failed_scaling_activities = false
  max_instance_lifetime            = 0
  max_size                         = 1
  min_elb_capacity                 = 0
  min_size                         = 1
  protect_from_scale_in            = false
  target_group_arns                = [aws_lb_target_group.TargetGroup1.arn]
  vpc_zone_identifier              = [aws_subnet.Subnet3.id, aws_subnet.Subnet.id, aws_subnet.Subnet1.id, aws_subnet.Subnet4.id]
  wait_for_elb_capacity            = 0
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }
  launch_template {
    version = "$Latest"
    id      = aws_launch_template.Template.id
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ASG"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "State1"
  }
  tag {
    key                 = "CloudmanUser"
    propagate_at_launch = true
    value               = "GlobalUserName"
  }
  tag {
    key                 = "cloud"
    propagate_at_launch = true
    value               = "minhacloud"
  }
}

resource "aws_subnet" "Subnet" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.0.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_subnet" "Subnet7" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.2.13.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet7"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_subnet" "Subnet1" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_subnet" "Subnet8" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.2.12.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet8"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_subnet" "Subnet4" {
  vpc_id                  = aws_vpc.VPC2.id
  availability_zone       = "us-east-1c"
  cidr_block              = "10.2.2.0/24"
  map_public_ip_on_launch = true
  tags                              = {
    "Name"         = "Subnet4"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

data "local_file" "UserData_Instance" {
  filename = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Instance" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance" {
  subnet_id                         = aws_subnet.Subnet4.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance.name
  instance_type                     = "t3.micro"
  secondary_private_ips             = ["10.2.2.10"]
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo "AWS_S3_BUCKET_TARGET_NAME_0=my-bucket-1234-teste-xxx" > /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=Instance" >> /home/ec2-user/.env
echo "AWS_S3_BUCKET_TARGET_ARN_0=${aws_s3_bucket.my-bucket-1234-teste-xxx.arn}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Instance.content}
EOFUData
  )
  user_data_replace_on_change = false
  vpc_security_group_ids      = [aws_security_group.SG_ec2.id]
  tags                              = {
    "Name"         = "Instance"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_s3_bucket" "my-bucket-1234-teste-xxx" {
  bucket              = "my-bucket-1234-teste-xxx"
  force_destroy       = true
  object_lock_enabled = false
  tags                              = {
    "Name"         = "my-bucket-1234-teste-xxx"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

data "local_file" "UserData_Template" {
  filename = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Template" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Template" {
  image_id                          = data.aws_ami.AMI_Data_Source_Template.id
  name                              = "Template"
  ebs_optimized                     = true
  instance_type                     = "t3.micro"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo "AWS_S3_BUCKET_TARGET_NAME_0=my-bucket-1234-teste-xxx" > /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=ASG" >> /home/ec2-user/.env
echo "AWS_S3_BUCKET_TARGET_ARN_0=${aws_s3_bucket.my-bucket-1234-teste-xxx.arn}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Template.content}
EOFUData
  )
  iam_instance_profile {
    name = aws_iam_instance_profile.profile_ASG.name
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      block_duration_minutes         = 0
      instance_interruption_behavior = "terminate"
      spot_instance_type             = "one-time"
    }
  }
  network_interfaces {
    associate_public_ip_address = "true"
    delete_on_termination       = "true"
    ipv4_address_count          = 1
    security_groups             = [aws_security_group.SG_ASG.id]
  }
  tags                              = {
    "Name"         = "Template"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_lb" "ALB1" {
  name               = "ALB1"
  idle_timeout       = 60
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG_ALB.id]
  subnets            = [aws_subnet.Subnet7.id, aws_subnet.Subnet8.id]
  tags                              = {
    "Name"         = "ALB1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_route_table" "RT2" {
  vpc_id = aws_vpc.VPC2.id
  tags                              = {
    "Name"         = "RT2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_internet_gateway" "IGW2" {
  vpc_id = aws_vpc.VPC2.id
  tags                              = {
    "Name"         = "IGW2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_lb_listener" "Listener1" {
  load_balancer_arn                    = aws_lb.ALB1.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.TargetGroup1.arn
    type             = "forward"
  }
  tags                              = {
    "Name"         = "Listener1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_lb_target_group" "TargetGroup1" {
  name                          = "TargetGroup1"
  vpc_id                        = aws_vpc.VPC2.id
  connection_termination        = false
  deregistration_delay          = "300"
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  port                          = 80
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  proxy_protocol_v2             = false
  slow_start                    = 0
  target_type                   = "instance"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
  tags                              = {
    "Name"         = "TargetGroup1"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_security_group" "SG_ASG" {
  name                   = "SG_ASG"
  vpc_id                 = aws_vpc.VPC2.id
  revoke_rules_on_delete = false
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    self        = false
    to_port     = 80
  }
  tags                              = {
    "Name"         = "SG_ASG"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_security_group" "SG_ALB" {
  name                   = "SG_ALB"
  vpc_id                 = aws_vpc.VPC2.id
  revoke_rules_on_delete = false
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    self        = false
    to_port     = 80
  }
  tags                              = {
    "Name"         = "SG_ALB"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_security_group" "SG_ec2" {
  name                   = "SG_ec2"
  vpc_id                 = aws_vpc.VPC2.id
  revoke_rules_on_delete = false
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    self        = false
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    self        = false
    to_port     = 80
  }
  tags                              = {
    "Name"         = "SG_ec2"
    "State"        = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud"        = "minhacloud"
  }
}

resource "aws_iam_role" "role_ASG" {
  name = "role_ASG"
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
}

resource "aws_iam_instance_profile" "profile_ASG" {
  name = "profile_ASG"
  role = aws_iam_role.role_ASG.name
}

resource "aws_iam_role" "role_Instance" {
  name = "role_Instance"
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
}

resource "aws_iam_instance_profile" "profile_Instance" {
  name = "profile_Instance"
  role = aws_iam_role.role_Instance.name
}

resource "aws_route_table_association" "aws_route_table_association_Subnet3_RT2" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.Subnet3.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet_RT2" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.Subnet.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet7_RT2" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.Subnet7.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet1_RT2" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.Subnet1.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet8_RT2" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.Subnet8.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet4_RT2" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.Subnet4.id
}

resource "aws_route" "aws_route_RT2_IGW2" {
  gateway_id             = aws_internet_gateway.IGW2.id
  route_table_id         = aws_route_table.RT2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_s3_bucket_versioning" "my-bucket-1234-teste-xxx_versioning" {
  bucket = aws_s3_bucket.my-bucket-1234-teste-xxx.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "my-bucket-1234-teste-xxx_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.my-bucket-1234-teste-xxx.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-1234-teste-xxx_configuration" {
  bucket                = aws_s3_bucket.my-bucket-1234-teste-xxx.id
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-1234-teste-xxx_controls" {
  bucket = aws_s3_bucket.my-bucket-1234-teste-xxx.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "policy_ASG_st_State1_doc" {
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["${aws_s3_bucket.my-bucket-1234-teste-xxx.arn}"]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.my-bucket-1234-teste-xxx.arn}/*"]
  }
}

resource "aws_iam_policy" "policy_ASG_st_State1" {
  name        = "policy_ASG_st_State1"
  description = "Combined Policy for ASG in state State1"
  policy      = data.aws_iam_policy_document.policy_ASG_st_State1_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_ASG_st_State1_attach" {
  policy_arn = aws_iam_policy.policy_ASG_st_State1.arn
  role       = "role_ASG"
}

data "aws_iam_policy_document" "policy_Instance_st_State1_doc" {
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["${aws_s3_bucket.my-bucket-1234-teste-xxx.arn}"]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.my-bucket-1234-teste-xxx.arn}/*"]
  }
}

resource "aws_iam_policy" "policy_Instance_st_State1" {
  name        = "policy_Instance_st_State1"
  description = "Combined Policy for Instance in state State1"
  policy      = data.aws_iam_policy_document.policy_Instance_st_State1_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_Instance_st_State1_attach" {
  policy_arn = aws_iam_policy.policy_Instance_st_State1.arn
  role       = "role_Instance"
}