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

### EXTERNAL REFERENCES ###

data "aws_secretsmanager_secret" "Secret" {
  name                              = "Secret"
}

data "aws_secretsmanager_secret_version" "SecVersion" {
  secret_id                         = data.aws_secretsmanager_secret.Secret.id
}




### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_InstancePol" {
  name                              = "profile_InstancePol"
  role                              = aws_iam_role.role_InstancePol.name
  tags                              = {
    "Name" = "profile_InstancePol"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

data "aws_iam_policy_document" "instance_InstancePol_st_State12_doc" {
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

resource "aws_iam_policy" "instance_InstancePol_st_State12" {
  name                              = "instance_InstancePol_st_State12"
  description                       = "Access Policy for InstancePol in State12"
  policy                            = data.aws_iam_policy_document.instance_InstancePol_st_State12_doc.json
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
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_iam_role_policy_attachment" "instance_InstancePol_st_State12_attach" {
  policy_arn                        = aws_iam_policy.instance_InstancePol_st_State12.arn
  role                              = aws_iam_role.role_InstancePol.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC1" {
  cidr_block                        = "10.0.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet11" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.2.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet11"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet5" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.3.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet5"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
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
    "stagex" = "minhacloud"
  }
}

resource "aws_subnet" "SubnetRDS" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "SubnetRDS"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    "Name" = "IGW"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
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
    "stagex" = "minhacloud"
  }
}

resource "aws_route_table_association" "aws_route_table_association_SubnetPolicy_RT" {
  route_table_id                    = aws_route_table.RT.id
  subnet_id                         = aws_subnet.SubnetPolicy.id
}

resource "aws_security_group" "SG_db_instance_Database1" {
  name                              = "SG_db_instance_Database1"
  vpc_id                            = aws_vpc.VPC1.id
  description                       = "Default SG for db_instance Database1"
  egress {
    cidr_blocks                     = ["0.0.0.0/0"]
    description                     = "Allow all outbound traffic"
    from_port                       = 0
    protocol                        = "-1"
    to_port                         = 0
  }
  tags                              = {
    "Name" = "SG_db_instance_Database1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
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
  tags                              = {
    "Name" = "SG_instance_InstancePol"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}




### CATEGORY: STORAGE ###

resource "aws_db_instance" "Database1" {
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_Database1.name
  allocated_storage                 = 20
  availability_zone                 = aws_subnet.Subnet11.availability_zone
  backup_retention_period           = 0
  copy_tags_to_snapshot             = true
  delete_automated_backups          = false
  engine                            = "mysql"
  engine_version                    = "8.0"
  instance_class                    = "db.t3.micro"
  max_allocated_storage             = 100
  password                          = jsondecode(data.aws_secretsmanager_secret_version.SecVersion.secret_string)["password"]
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  upgrade_storage_config            = false
  username                          = jsondecode(data.aws_secretsmanager_secret_version.SecVersion.secret_string)["username"]
  vpc_security_group_ids            = [aws_security_group.SG_db_instance_Database1.id]
  tags                              = {
    "Name" = "Database1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_db_subnet_group" "subnet_group_Database1" {
  name                              = "database1-subnet-group"
  subnet_ids                        = [aws_subnet.Subnet11.id, aws_subnet.Subnet5.id]
  tags                              = {
    "Name" = "subnet_group_Database1"
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
echo "AWS_DB_INSTANCE_TARGET_NAME_0=Database1" > /home/ec2-user/.env
echo "AWS_SECRETSMANAGER_SECRET_TARGET_NAME_0=Secret" >> /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=InstancePol" >> /home/ec2-user/.env
echo "AWS_DB_INSTANCE_TARGET_ARN_0=${aws_db_instance.Database1.arn}" >> /home/ec2-user/.env
echo "AWS_SECRETSMANAGER_SECRET_TARGET_ARN_0=${data.aws_secretsmanager_secret.Secret.arn}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.SG_instance_InstancePol.id]
  tags                              = {
    "Name" = "InstancePol"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}


