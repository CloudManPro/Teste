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
    key            = "061051249868/State18/main.tfstate"
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

### EXTERNAL REFERENCES ###

data "aws_vpc" "VPC1" {
  filter {
    name                            = "tag:Name"
    values                          = ["VPC1"]
  }
}

data "aws_db_instance" "rds1" {
  db_instance_identifier            = "rds1"
}

data "aws_internet_gateway" "IGW" {
  filter {
    name                            = "tag:Name"
    values                          = ["IGW"]
  }
}

data "aws_security_group" "SG" {
  filter {
    name                            = "tag:Name"
    values                          = ["SG"]
  }
}

data "aws_lb_target_group" "TG" {
  name                              = "TG"
}

data "aws_secretsmanager_secret" "Secret" {
  name                              = "Secret"
}




### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_InstancePol" {
  name                              = "profile_InstancePol"
  role                              = aws_iam_role.role_InstancePol.name
  tags                              = {
    "Name" = "profile_InstancePol"
    "State" = "State18"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_iam_policy_document" "instance_InstancePol_st_State18_doc" {
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
  statement {
    sid                             = "AllowSecretAccess"
    effect                          = "Allow"
    actions                         = ["secretsmanager:GetSecretValue"]
    resources                       = ["${data.aws_secretsmanager_secret.Secret.arn}"]
  }
}

resource "aws_iam_policy" "instance_InstancePol_st_State18" {
  name                              = "instance_InstancePol_st_State18"
  description                       = "Access Policy for InstancePol in State18"
  policy                            = data.aws_iam_policy_document.instance_InstancePol_st_State18_doc.json
}

resource "aws_iam_role" "role_InstancePol" {
  name                              = "role_InstancePol"
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
    "Name" = "role_InstancePol"
    "State" = "State18"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "instance_InstancePol_st_State18_attach" {
  policy_arn                        = aws_iam_policy.instance_InstancePol_st_State18.arn
  role                              = aws_iam_role.role_InstancePol.name
}




### CATEGORY: NETWORK ###

resource "aws_subnet" "SubnetPolicy" {
  vpc_id                            = data.aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "SubnetPolicy"
    "State" = "State18"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT_IGW" {
  gateway_id                        = data.aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT" {
  vpc_id                            = data.aws_vpc.VPC1.id
  tags                              = {
    "Name" = "RT"
    "State" = "State18"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_SubnetPolicy_RT" {
  route_table_id                    = aws_route_table.RT.id
  subnet_id                         = aws_subnet.SubnetPolicy.id
}

resource "aws_security_group" "InstancePol_group" {
  name                              = "InstancePol_group"
  vpc_id                            = data.aws_vpc.VPC1.id
  revoke_rules_on_delete            = false
  egress {
    from_port                       = 0
    protocol                        = "-1"
    self                            = false
    to_port                         = 0
  }
  tags                              = {
    "Name" = "InstancePol_group"
    "State" = "State18"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group_rule" "rule_InstancePol_group_to_SG" {
  security_group_id                 = data.aws_security_group.SG.id
  source_security_group_id          = aws_security_group.InstancePol_group.id
  description                       = "Allow from InstancePol_group"
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "ingress"
}

resource "aws_lb_target_group_attachment" "attach_InstancePol_to_TG" {
  target_id                         = aws_instance.InstancePol.id
  port                              = 80
  target_group_arn                  = data.aws_lb_target_group.TG.arn
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_InstancePol" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "InstancePol" {
  subnet_id                         = aws_subnet.SubnetPolicy.id
  ami                               = data.aws_ami.AMI_Data_Source_InstancePol.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_InstancePol.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo "AWS_SECRETSMANAGER_SECRET_TARGET_NAME_0=Secret" > /home/ec2-user/.env
echo "AWS_DB_INSTANCE_TARGET_NAME_0=rds1" >> /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=InstancePol" >> /home/ec2-user/.env
echo "AWS_DB_INSTANCE_TARGET_ARN_0=${data.aws_db_instance.rds1.arn}" >> /home/ec2-user/.env
echo "AWS_DB_INSTANCE_TARGET_ENDPOINT_0=${data.aws_db_instance.rds1.endpoint}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.InstancePol_group.id]
  tags                              = {
    "Name" = "InstancePol"
    "State" = "State18"
    "CloudmanUser" = "GlobalUserName"
  }
}


