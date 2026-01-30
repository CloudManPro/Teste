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
    key            = "061051249868/State27/main.tfstate"
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

resource "aws_iam_role" "execution_role_MICRO1" {
  name                              = "execution_role_MICRO1"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "execution_role_MICRO1"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "task_role_MICRO1" {
  name                              = "task_role_MICRO1"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "task_role_MICRO1"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC8" {
  cidr_block                        = "10.7.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC8"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet19" {
  vpc_id                            = aws_vpc.VPC8.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.7.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet19"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW5" {
  vpc_id                            = aws_vpc.VPC8.id
  tags                              = {
    "Name" = "IGW5"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT7_IGW5" {
  gateway_id                        = aws_internet_gateway.IGW5.id
  route_table_id                    = aws_route_table.RT7.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT7" {
  vpc_id                            = aws_vpc.VPC8.id
  tags                              = {
    "Name" = "RT7"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet19_RT7" {
  route_table_id                    = aws_route_table.RT7.id
  subnet_id                         = aws_subnet.Subnet19.id
}

resource "aws_security_group" "SG1" {
  name                              = "SG1"
  vpc_id                            = aws_vpc.VPC8.id
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
    "Name" = "SG1"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: COMPUTE ###

resource "aws_ecs_cluster" "ECSCluster" {
  name                              = "ECSCluster"
  tags                              = {
    "Name" = "ECSCluster"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_ecs_service" "MICRO1_service" {
  name                              = "MICRO1_service"
  cluster                           = aws_ecs_cluster.ECSCluster.id
  desired_count                     = 1
  enable_ecs_managed_tags           = true
  force_delete                      = true
  launch_type                       = "FARGATE"
  propagate_tags                    = "TASK_DEFINITION"
  task_definition                   = aws_ecs_task_definition.MICRO1.arn
  deployment_circuit_breaker {
    enable                          = false
    rollback                        = false
  }
  deployment_controller {
    type                            = "ECS"
  }
  network_configuration {
    assign_public_ip                = true
    security_groups                 = [aws_security_group.SG1.id]
    subnets                         = [aws_subnet.Subnet19.id]
  }
  tags                              = {
    "Name" = "MICRO1_service"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

locals {
  container_def_MICRO1_Container = {
    "name" = "Container"
    "image" = "nginx:latest"
    "essential" = true
    "cpu" = 128
    "memory" = 256
    "environment" = [{
    "name" = "AWS_ECS_TASK_DEFINITION_TARGET_NAME_0"
    "value" = "MICRO1"
  }, {
    "name" = "AWS_ECS_SERVICE_TARGET_NAME_0"
    "value" = "MICRO1_service"
  }]
    "privileged" = false
    "readonlyRootFilesystem" = false
  }
}

resource "aws_ecs_task_definition" "MICRO1" {
  container_definitions             = jsonencode([local.container_def_MICRO1_Container])
  cpu                               = "1024"
  execution_role_arn                = aws_iam_role.execution_role_MICRO1.arn
  family                            = "app"
  memory                            = "2048"
  network_mode                      = "awsvpc"
  requires_compatibilities          = ["FARGATE"]
  task_role_arn                     = aws_iam_role.task_role_MICRO1.arn
  tags                              = {
    "Name" = "MICRO1"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}


