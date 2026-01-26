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
  name = "Secret"
}

data "aws_secretsmanager_secret_version" "SecVersion" {
  secret_id                         = data.aws_secretsmanager_secret.Secret.id
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

resource "aws_subnet" "Subnet13" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet13"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_subnet" "Subnet14" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.4.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet14"
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

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    "Name" = "IGW"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_route" "aws_route_RT5_IGW" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT5.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT5" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    "Name" = "RT5"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet13_RT5" {
  route_table_id                    = aws_route_table.RT5.id
  subnet_id                         = aws_subnet.Subnet13.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet14_RT5" {
  route_table_id                    = aws_route_table.RT5.id
  subnet_id                         = aws_subnet.Subnet14.id
}

resource "aws_security_group" "ALB3_group" {
  name                              = "ALB3_group"
  vpc_id                            = aws_vpc.VPC1.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "ALB3_group"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_security_group" "SG" {
  name                              = "SG"
  vpc_id                            = aws_vpc.VPC1.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "SG"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_security_group" "rds1_group" {
  name                              = "rds1_group"
  vpc_id                            = aws_vpc.VPC1.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "rds1_group"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_security_group_rule" "rule_ALB3_group_to_SG" {
  security_group_id                 = aws_security_group.SG.id
  source_security_group_id          = aws_security_group.ALB3_group.id
  description                       = "Allow from ALB3_group"
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "ingress"
}

resource "aws_lb" "ALB3" {
  name                              = "ALB3"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.ALB3_group.id]
  subnets                           = [aws_subnet.Subnet13.id, aws_subnet.Subnet14.id]
  tags                              = {
    "Name" = "ALB3"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_lb_listener" "Listener3" {
  load_balancer_arn                 = aws_lb.ALB3.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG.arn
    type                            = "forward"
  }
  tags                              = {
    "Name" = "Listener3"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_lb_target_group" "TG" {
  name                              = "TG"
  vpc_id                            = aws_vpc.VPC1.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  port                              = 80
  protocol                          = "HTTP"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "instance"
  tags                              = {
    "Name" = "TG"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}




### CATEGORY: STORAGE ###

resource "aws_db_instance" "rds1" {
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_rds1.name
  allocated_storage                 = 20
  availability_zone                 = aws_subnet.Subnet11.availability_zone
  backup_retention_period           = 0
  copy_tags_to_snapshot             = true
  delete_automated_backups          = false
  engine                            = "mysql"
  engine_version                    = "8.0"
  identifier                        = "rds1"
  instance_class                    = "db.t3.micro"
  max_allocated_storage             = 100
  password                          = jsondecode(data.aws_secretsmanager_secret_version.SecVersion.secret_string)["password"]
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  upgrade_storage_config            = false
  username                          = jsondecode(data.aws_secretsmanager_secret_version.SecVersion.secret_string)["username"]
  vpc_security_group_ids            = [aws_security_group.SG.id, aws_security_group.rds1_group.id]
  tags                              = {
    "Name" = "rds1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
    "stagex" = "minhacloud"
  }
}

resource "aws_db_subnet_group" "subnet_group_rds1" {
  name                              = "rds1-subnet-group"
  subnet_ids                        = [aws_subnet.Subnet5.id, aws_subnet.Subnet11.id]
  tags                              = {
    "Name" = "subnet_group_rds1"
    "State" = "State12"
    "CloudmanUser" = "GlobalUserName"
  }
}


