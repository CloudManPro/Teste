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
    key            = "952133486861/State23/main.tfstate"
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

### SYSTEM DATA SOURCES ###

data "aws_route53_zone" "Cloudman1" {
  name                              = "cloudman.pro"
}

data "aws_cloudfront_origin_request_policy" "policy_allviewer" {
  name                              = "Managed-AllViewer"
}

data "aws_cloudfront_cache_policy" "policy_cachingdisabled" {
  name                              = "Managed-CachingDisabled"
}




### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_Instance4" {
  name                              = "profile_Instance4"
  role                              = aws_iam_role.role_Instance4.name
  tags                              = {
    "Name" = "profile_Instance4"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_iam_policy_document" "instance_Instance4_st_State23_doc" {
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

resource "aws_iam_policy" "instance_Instance4_st_State23" {
  name                              = "instance_Instance4_st_State23"
  description                       = "Access Policy for Instance4 in State23"
  policy                            = data.aws_iam_policy_document.instance_Instance4_st_State23_doc.json
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
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "instance_Instance4_st_State23_attach" {
  policy_arn                        = aws_iam_policy.instance_Instance4_st_State23.arn
  role                              = aws_iam_role.role_Instance4.name
}

resource "aws_acm_certificate" "Certificate2" {
  domain_name                       = "testecf.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  tags                              = {
    "Name" = "Certificate2"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_acm_certificate" "Certificate3" {
  domain_name                       = "testealb.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  tags                              = {
    "Name" = "Certificate3"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate2" {
  certificate_arn                   = aws_acm_certificate.Certificate2.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate2 : record.fqdn]
}

resource "aws_acm_certificate_validation" "Validation_Certificate3" {
  certificate_arn                   = aws_acm_certificate.Certificate3.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate3 : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC4" {
  cidr_block                        = "10.3.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC4"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet45" {
  vpc_id                            = aws_vpc.VPC4.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.3.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet45"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_subnet" "Subnet46" {
  vpc_id                            = aws_vpc.VPC4.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.3.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet46"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_internet_gateway" "IGW1" {
  vpc_id                            = aws_vpc.VPC4.id
  tags                              = {
    "Name" = "IGW1"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route" "aws_route_RT3_IGW1" {
  gateway_id                        = aws_internet_gateway.IGW1.id
  route_table_id                    = aws_route_table.RT3.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route53_record" "Route53_Record_Certificate2" {
  for_each                          = {for dvo in aws_acm_certificate.Certificate2.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.Cloudman1.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}

resource "aws_route53_record" "Route53_Record_Certificate3" {
  for_each                          = {for dvo in aws_acm_certificate.Certificate3.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.Cloudman1.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}

resource "aws_route53_record" "alias_a_testealb_to_lb_ALB" {
  name                              = "testealb.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman1.zone_id
  type                              = "A"
  alias {
    name                            = aws_lb.ALB.dns_name
    zone_id                         = aws_lb.ALB.zone_id
    evaluate_target_health          = true
  }
}

resource "aws_route53_record" "alias_a_testecf1_to_CDN3" {
  name                              = "testecf.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman1.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.CDN3.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN3.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_testecf1_to_CDN3" {
  name                              = "testecf.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman1.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.CDN3.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN3.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route_table" "RT3" {
  vpc_id                            = aws_vpc.VPC4.id
  tags                              = {
    "Name" = "RT3"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet45_RT3" {
  route_table_id                    = aws_route_table.RT3.id
  subnet_id                         = aws_subnet.Subnet45.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet46_RT3" {
  route_table_id                    = aws_route_table.RT3.id
  subnet_id                         = aws_subnet.Subnet46.id
}

resource "aws_security_group" "ALB_group" {
  name                              = "ALB_group"
  vpc_id                            = aws_vpc.VPC4.id
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
    "Name" = "ALB_group"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_security_group" "Instance4_group" {
  name                              = "Instance4_group"
  vpc_id                            = aws_vpc.VPC4.id
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
    "Name" = "Instance4_group"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb" "ALB" {
  name                              = "ALB"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  subnets                           = [aws_subnet.Subnet45.id, aws_subnet.Subnet46.id]
  tags                              = {
    "Name" = "ALB"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_listener" "Listener" {
  load_balancer_arn                 = aws_lb.ALB.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TargetGroup.arn
    type                            = "forward"
  }
  tags                              = {
    "Name" = "Listener"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group" "TargetGroup" {
  name                              = "TargetGroup"
  vpc_id                            = aws_vpc.VPC4.id
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
    "Name" = "TargetGroup"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_lb_target_group_attachment" "attach_Instance4_to_TargetGroup" {
  target_id                         = aws_instance.Instance4.id
  port                              = 80
  target_group_arn                  = aws_lb_target_group.TargetGroup.arn
}

resource "aws_cloudfront_distribution" "CDN3" {
  aliases                           = ["testecf.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingdisabled.id
    origin_request_policy_id        = data.aws_cloudfront_origin_request_policy.policy_allviewer.id
    target_origin_id                = "default_CDN3"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_lb.ALB.dns_name
    origin_id                       = "default_CDN3"
    custom_origin_config {
      http_port                     = 80
      https_port                    = 443
      origin_protocol_policy        = "http-only"
      origin_ssl_protocols          = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CDN3"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.Certificate2.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_Instance4" {
  filename                          = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Instance4" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance4" {
  subnet_id                         = aws_subnet.Subnet45.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance4.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance4.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo "AWS_SECURITY_GROUP_TARGET_NAME_0=Instance4_group" > /home/ec2-user/.env
echo "REGION=${data.aws_region.current.name}" >> /home/ec2-user/.env
echo "ACCOUNT=${data.aws_caller_identity.current.account_id}" >> /home/ec2-user/.env
echo "NAME=Instance4" >> /home/ec2-user/.env
echo "AWS_SECURITY_GROUP_TARGET_ARN_0=${aws_security_group.Instance4_group.arn}" >> /home/ec2-user/.env
# --- END CLOUDMAN VARIABLES ---

${data.local_file.UserData_Instance4.content}
EOFUData
)
  user_data_replace_on_change       = false
  tags                              = {
    "Name" = "Instance4"
    "State" = "State23"
    "CloudmanUser" = "GlobalUserName"
  }
}


