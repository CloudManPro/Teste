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
    key            = "061051249868/State12/main.tfstate"
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

resource "aws_iam_instance_profile" "profile_InstancePol" {
  name                              = "profile_InstancePol"
  role                              = aws_iam_role.role_InstancePol.name
}

data "aws_iam_policy_document" "policy_InstancePol_consolidated_doc" {
  statement {
    effect                          = "Allow"
    actions                         = ["ec2-instance-connect:SendSSHPublicKey", "ec2:DescribeInstances", "ec2:GetConsoleOutput", "ec2:SendSerialConsoleSSHPublicKey", "ec2:GetConsoleScreenshot"]
    resources                       = ["*"]
  }
  statement {
    sid                             = "AllowSNSPublish"
    effect                          = "Allow"
    actions                         = ["sns:Publish"]
    resources                       = ["${aws_sns_topic.Topic1.arn}"]
  }
}

resource "aws_iam_policy" "policy_InstancePol_consolidated" {
  name                              = "policy_InstancePol_consolidated"
  description                       = "Consolidated Policy for InstancePol"
  policy                            = data.aws_iam_policy_document.policy_InstancePol_consolidated_doc.json
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
}

resource "aws_iam_role_policy_attachment" "policy_InstancePol_consolidated_attach" {
  policy_arn                        = aws_iam_policy.policy_InstancePol_consolidated.arn
  role                              = "role_InstancePol"
}




### CATEGORY: NETWORK ###

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    "Name" = "IGW"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT_IGW" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    "Name" = "RT"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_SubnetPolicy_RT" {
  route_table_id                    = aws_route_table.RT.id
  subnet_id                         = aws_subnet.SubnetPolicy.id
}

resource "aws_security_group" "SG_instance_InstancePol" {
  name                              = "SG_instance_InstancePol"
  vpc_id                            = aws_vpc.VPC1.id
  description                       = "Default SG for instance InstancePol"
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    description                     = "Allow all outbound traffic"
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
}

resource "aws_subnet" "SubnetPolicy" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "SubnetPolicy"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_vpc" "VPC1" {
  cidr_block                        = "10.0.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
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
echo "AWS_SNS_TOPIC_TARGET_NAME_0=Topic1" > /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=InstancePol" >> /home/ec2-user/.env
echo "AWS_SNS_TOPIC_TARGET_ARN_0=${aws_sns_topic.Topic1.arn}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.SG_instance_InstancePol.id]
  tags                              = {
    "Name" = "InstancePol"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic1" {
  name                              = "Topic1"
  tags                              = {
    "Name" = "Topic1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
}


