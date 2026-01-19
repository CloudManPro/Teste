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

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_ASG" {
  name                              = "profile_ASG"
  role                              = aws_iam_role.role_ASG.name
}

resource "aws_iam_instance_profile" "profile_Instance" {
  name                              = "profile_Instance"
  role                              = aws_iam_role.role_Instance.name
}

data "aws_iam_policy_document" "policy_ASG_consolidated_doc" {
  statement {
    sid                             = "EC2AndConsoleAccess"
    effect                          = "Allow"
    actions                         = ["ec2-instance-connect:SendSSHPublicKey", "ec2:DescribeInstances", "ec2:GetConsoleOutput", "ec2:SendSerialConsoleSSHPublicKey", "ec2:GetConsoleScreenshot"]
    resources                       = ["*"]
  }
  statement {
    sid                             = "SSMSessionManagerPermissions"
    effect                          = "Allow"
    actions                         = ["ssm:UpdateInstanceInformation", "ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "policy_ASG_consolidated" {
  name                              = "policy_ASG_consolidated"
  description                       = "Consolidated Policy for ASG"
  policy                            = data.aws_iam_policy_document.policy_ASG_consolidated_doc.json
}

data "aws_iam_policy_document" "policy_Instance_consolidated_doc" {
  statement {
    sid                             = "EC2AndConsoleAccess"
    effect                          = "Allow"
    actions                         = ["ec2-instance-connect:SendSSHPublicKey", "ec2:DescribeInstances", "ec2:GetConsoleOutput", "ec2:SendSerialConsoleSSHPublicKey", "ec2:GetConsoleScreenshot"]
    resources                       = ["*"]
  }
  statement {
    sid                             = "SSMSessionManagerPermissions"
    effect                          = "Allow"
    actions                         = ["ssm:UpdateInstanceInformation", "ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "policy_Instance_consolidated" {
  name                              = "policy_Instance_consolidated"
  description                       = "Consolidated Policy for Instance"
  policy                            = data.aws_iam_policy_document.policy_Instance_consolidated_doc.json
}

resource "aws_iam_role" "role_ASG" {
  name                              = "role_ASG"
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

resource "aws_iam_role" "role_Instance" {
  name                              = "role_Instance"
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

resource "aws_iam_role_policy_attachment" "policy_ASG_consolidated_attach" {
  policy_arn                        = aws_iam_policy.policy_ASG_consolidated.arn
  role                              = aws_iam_role.role_ASG.name
}

resource "aws_iam_role_policy_attachment" "policy_Instance_consolidated_attach" {
  policy_arn                        = aws_iam_policy.policy_Instance_consolidated.arn
  role                              = aws_iam_role.role_Instance.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC2" {
  cidr_block                        = "10.2.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC2"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet" {
  vpc_id                            = aws_vpc.VPC2.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.2.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet1" {
  vpc_id                            = aws_vpc.VPC2.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.2.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet1"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                            = aws_vpc.VPC2.id
  availability_zone                 = "us-east-1d"
  cidr_block                        = "10.2.14.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet2"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet3" {
  vpc_id                            = aws_vpc.VPC2.id
  availability_zone                 = "us-east-1d"
  cidr_block                        = "10.2.3.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet3"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet7" {
  vpc_id                            = aws_vpc.VPC2.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.2.13.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet7"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet8" {
  vpc_id                            = aws_vpc.VPC2.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.2.12.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet8"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_internet_gateway" "IGW2" {
  vpc_id                            = aws_vpc.VPC2.id
  tags                              = {
    "Name" = "IGW2"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_route" "aws_route_RT1_Instance" {
  network_interface_id              = aws_instance.Instance.primary_network_interface_id
  route_table_id                    = aws_route_table.RT1.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "aws_route_RT2_IGW2" {
  gateway_id                        = aws_internet_gateway.IGW2.id
  route_table_id                    = aws_route_table.RT2.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT1" {
  vpc_id                            = aws_vpc.VPC2.id
  tags                              = {
    "Name" = "RT1"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_route_table" "RT2" {
  vpc_id                            = aws_vpc.VPC2.id
  tags                              = {
    "Name" = "RT2"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet1_RT1" {
  route_table_id                    = aws_route_table.RT1.id
  subnet_id                         = aws_subnet.Subnet1.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet2_RT2" {
  route_table_id                    = aws_route_table.RT2.id
  subnet_id                         = aws_subnet.Subnet2.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet3_RT1" {
  route_table_id                    = aws_route_table.RT1.id
  subnet_id                         = aws_subnet.Subnet3.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet7_RT2" {
  route_table_id                    = aws_route_table.RT2.id
  subnet_id                         = aws_subnet.Subnet7.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet8_RT2" {
  route_table_id                    = aws_route_table.RT2.id
  subnet_id                         = aws_subnet.Subnet8.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet_RT1" {
  route_table_id                    = aws_route_table.RT1.id
  subnet_id                         = aws_subnet.Subnet.id
}

resource "aws_security_group" "SG_ALB" {
  name                              = "SG_ALB"
  vpc_id                            = aws_vpc.VPC2.id
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
    "Name" = "SG_ALB"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_security_group" "SG_autoscaling_group_ASG" {
  name                              = "SG_autoscaling_group_ASG"
  vpc_id                            = aws_vpc.VPC2.id
  description                       = "Default SG for autoscaling_group ASG"
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    description                     = "Allow all outbound traffic"
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
  ingress {
    description                     = "alb80"
    from_port                       = 80
    protocol                        = "tcp"
    security_groups                 = [aws_security_group.SG_ALB.id]
    to_port                         = 80
  }
}

resource "aws_security_group" "SG_instance_Instance" {
  name                              = "SG_instance_Instance"
  vpc_id                            = aws_vpc.VPC2.id
  description                       = "Default SG for instance Instance"
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    description                     = "Allow all outbound traffic"
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
  ingress {
    description                     = "Allow from ASG"
    from_port                       = 0
    protocol                        = "-1"
    security_groups                 = [aws_security_group.SG_autoscaling_group_ASG.id]
    to_port                         = 0
  }
}

resource "aws_lb" "ALB1" {
  name                              = "ALB1"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.SG_ALB.id]
  subnets                           = [aws_subnet.Subnet8.id, aws_subnet.Subnet2.id, aws_subnet.Subnet7.id]
  tags                              = {
    "Name" = "ALB1"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_lb_listener" "Listener1" {
  load_balancer_arn                 = aws_lb.ALB1.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.Targetoup1.arn
    type                            = "forward"
  }
  tags                              = {
    "Name" = "Listener1"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_lb_target_group" "Targetoup1" {
  name                              = "Targetoup1"
  vpc_id                            = aws_vpc.VPC2.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
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
    "Name" = "Targetoup1"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_Instance" {
  filename                          = "${path.module}/.external_modules/CloudMan/EC2/NATGateway/NAT.sh"
}

data "aws_ami" "AMI_Data_Source_Instance" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance" {
  subnet_id                         = aws_subnet.Subnet8.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance.name
  instance_type                     = "t3.micro"
  source_dest_check                 = false
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo "REGION=${data.aws_region.current.name}" > /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=Instance" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Instance.content}
EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.SG_instance_Instance.id]
  enclave_options {
    enabled                         = false
  }
  lifecycle {
    create_before_destroy           = false
    prevent_destroy                 = false
  }
  metadata_options {
    http_protocol_ipv6              = "enabled"
    http_tokens                     = "required"
    instance_metadata_tags          = "enabled"
  }
  tags                              = {
    "Name" = "Instance"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

data "local_file" "UserData_Template" {
  filename                          = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Template" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
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
echo "AWS_INSTANCE_TARGET_NAME_0=Instance" > /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=ASG" >> /home/ec2-user/.env
echo "AWS_INSTANCE_TARGET_ARN_0=${aws_instance.Instance.arn}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Template.content}
EOFUData
)
  vpc_security_group_ids            = [aws_security_group.SG_autoscaling_group_ASG.id]
  iam_instance_profile {
    name                            = aws_iam_instance_profile.profile_ASG.name
  }
  tags                              = {
    "Name" = "Template"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
    "cloud" = "minhacloud"
  }
}

resource "aws_autoscaling_group" "ASG" {
  name                              = "ASG"
  capacity_rebalance                = true
  default_cooldown                  = 300
  default_instance_warmup           = 0
  desired_capacity                  = 1
  desired_capacity_type             = "units"
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_grace_period         = 300
  health_check_type                 = "ELB"
  ignore_failed_scaling_activities  = false
  max_instance_lifetime             = 0
  max_size                          = 1
  min_elb_capacity                  = 0
  min_size                          = 1
  protect_from_scale_in             = false
  target_group_arns                 = [aws_lb_target_group.Targetoup1.arn]
  vpc_zone_identifier               = [aws_subnet.Subnet3.id, aws_subnet.Subnet.id, aws_subnet.Subnet1.id]
  wait_for_elb_capacity             = 0
  availability_zone_distribution {
    capacity_distribution_strategy  = "balanced-best-effort"
  }
  capacity_reservation_specification {
  }
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template.id
  }
  tag {
    key                             = "Name"
    propagate_at_launch             = true
    value                           = "ASG"
  }
  tag {
    key                             = "State"
    propagate_at_launch             = true
    value                           = "State1"
  }
  tag {
    key                             = "CloudmanUser"
    propagate_at_launch             = true
    value                           = "GlobalUserName"
  }
  tag {
    key                             = "cloud"
    propagate_at_launch             = true
    value                           = "minhacloud"
  }
}


