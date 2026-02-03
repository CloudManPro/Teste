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
    key            = "061051249868/State30/main.tfstate"
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

resource "aws_iam_role" "role_eks_eks_cluster" {
  name                              = "role_eks_eks_cluster"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_eks_eks_cluster"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_eksng_Node" {
  name                              = "role_eksng_Node"
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
    "Name" = "role_eksng_Node"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEC2ContainerRegistryReadOnly_to_Node" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role                              = aws_iam_role.role_eksng_Node.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSClusterPolicy_to_eks_cluster" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role                              = aws_iam_role.role_eks_eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSWorkerNodePolicy_to_Node" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role                              = aws_iam_role.role_eksng_Node.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKS_CNI_Policy_to_Node" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role                              = aws_iam_role.role_eksng_Node.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC11" {
  cidr_block                        = "10.10.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC11"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet22" {
  vpc_id                            = aws_vpc.VPC11.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.10.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/eks_cluster" = "shared"
    "Name" = "Subnet22"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet23" {
  vpc_id                            = aws_vpc.VPC11.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.10.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/eks_cluster" = "shared"
    "Name" = "Subnet23"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet24" {
  vpc_id                            = aws_vpc.VPC11.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.10.2.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet24"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW7" {
  vpc_id                            = aws_vpc.VPC11.id
  tags                              = {
    "Name" = "IGW7"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT9_IGW7" {
  gateway_id                        = aws_internet_gateway.IGW7.id
  route_table_id                    = aws_route_table.RT9.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT9" {
  vpc_id                            = aws_vpc.VPC11.id
  tags                              = {
    "Name" = "RT9"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet22_RT9" {
  route_table_id                    = aws_route_table.RT9.id
  subnet_id                         = aws_subnet.Subnet22.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet23_RT9" {
  route_table_id                    = aws_route_table.RT9.id
  subnet_id                         = aws_subnet.Subnet23.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet24_RT9" {
  route_table_id                    = aws_route_table.RT9.id
  subnet_id                         = aws_subnet.Subnet24.id
}

resource "aws_security_group" "eks_node_group_Node_group" {
  name                              = "eks_node_group_Node_group"
  vpc_id                            = aws_vpc.VPC11.id
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
    "Name" = "eks_node_group_Node_group"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: COMPUTE ###


resource "aws_launch_template" "Template3" {
  name                              = "Template3"
  ebs_optimized                     = true
  instance_type                     = "t3.small"
  update_default_version            = true
  vpc_security_group_ids            = [aws_security_group.eks_node_group_Node_group.id]
  tags                              = {
    "Name" = "Template3"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  version                           = "1.30"
  name                              = "eks_cluster"
  bootstrap_self_managed_addons     = true
  deletion_protection               = false
  force_update_version              = false
  role_arn                          = aws_iam_role.role_eks_eks_cluster.arn
  access_config {
    authentication_mode             = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  compute_config {
    enabled                         = false
    node_role_arn                   = aws_iam_role.role_eks_eks_cluster.arn
  }
  kubernetes_network_config {
    ip_family                       = "ipv4"
    elastic_load_balancing {
      enabled                       = false
    }
  }
  tags                              = {
    "Name" = "eks_cluster"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
  vpc_config {
    endpoint_private_access         = true
    endpoint_public_access          = true
    public_access_cidrs             = ["0.0.0.0/0"]
    subnet_ids                      = [aws_subnet.Subnet22.id, aws_subnet.Subnet23.id]
  }
  depends_on                        = [aws_iam_role_policy_attachment.attach_AmazonEKSClusterPolicy_to_eks_cluster]
}

resource "aws_eks_node_group" "Node" {
  version                           = "1.30"
  cluster_name                      = aws_eks_cluster.eks_cluster.name
  node_group_name                   = "Node"
  node_role_arn                     = aws_iam_role.role_eksng_Node.arn
  subnet_ids                        = [aws_subnet.Subnet24.id]
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template3.id
  }
  scaling_config {
    desired_size                    = 1
    max_size                        = 2
    min_size                        = 1
  }
  tags                              = {
    "Name" = "Node"
    "State" = "State30"
    "CloudmanUser" = "GlobalUserName"
  }
  depends_on                        = [aws_iam_role_policy_attachment.attach_AmazonEKSWorkerNodePolicy_to_Node, aws_iam_role_policy_attachment.attach_AmazonEKS_CNI_Policy_to_Node, aws_iam_role_policy_attachment.attach_AmazonEC2ContainerRegistryReadOnly_to_Node]
}


