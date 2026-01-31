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

resource "aws_iam_instance_profile" "profile_ASG2" {
  name                              = "profile_ASG2"
  role                              = aws_iam_role.role_ASG2.name
  tags                              = {
    "Name" = "profile_ASG2"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

data "aws_iam_policy_document" "autoscaling_group_ASG2_st_State27_doc" {
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
    effect                          = "Allow"
    actions                         = ["ecs:RegisterContainerInstance", "ecs:DeregisterContainerInstance", "ecs:DiscoverPollEndpoint", "ecs:Submit*", "ecs:Poll", "ecs:StartTelemetrySession"]
    resources                       = ["${aws_ecs_cluster.ECSCluster.arn}"]
  }
}

resource "aws_iam_policy" "autoscaling_group_ASG2_st_State27" {
  name                              = "autoscaling_group_ASG2_st_State27"
  description                       = "Access Policy for ASG2"
  policy                            = data.aws_iam_policy_document.autoscaling_group_ASG2_st_State27_doc.json
}

data "aws_iam_policy_document" "ecs_task_definition_MICRO1_execution_st_State27_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources                       = ["${aws_cloudwatch_log_group.ECSLogs.arn}:*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_MICRO1_execution_st_State27" {
  name                              = "ecs_task_definition_MICRO1_execution_st_State27"
  description                       = "Access Policy for MICRO1 (Role: execution)"
  policy                            = data.aws_iam_policy_document.ecs_task_definition_MICRO1_execution_st_State27_doc.json
}

data "aws_iam_policy_document" "ecs_task_definition_MICRO1_task_st_State27_doc" {
  statement {
    sid                             = "AllowSNSPublish"
    effect                          = "Allow"
    actions                         = ["sns:Publish"]
    resources                       = ["${aws_sns_topic.Topic4.arn}"]
  }
  statement {
    sid                             = "AllowSQSActions"
    effect                          = "Allow"
    actions                         = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources                       = ["${aws_sqs_queue.Queue2.arn}"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_MICRO1_task_st_State27" {
  name                              = "ecs_task_definition_MICRO1_task_st_State27"
  description                       = "Access Policy for MICRO1 (Role: task)"
  policy                            = data.aws_iam_policy_document.ecs_task_definition_MICRO1_task_st_State27_doc.json
}

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

resource "aws_iam_role" "role_ASG2" {
  name                              = "role_ASG2"
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
    "Name" = "role_ASG2"
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

resource "aws_iam_role_policy_attachment" "attach_service_role_AmazonEC2ContainerServiceforEC2Role_to_ASG2" {
  policy_arn                        = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role                              = aws_iam_role.role_ASG2.name
}

resource "aws_iam_role_policy_attachment" "autoscaling_group_ASG2_st_State27_attach" {
  policy_arn                        = aws_iam_policy.autoscaling_group_ASG2_st_State27.arn
  role                              = aws_iam_role.role_ASG2.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_MICRO1_execution_st_State27_attach" {
  policy_arn                        = aws_iam_policy.ecs_task_definition_MICRO1_execution_st_State27.arn
  role                              = aws_iam_role.execution_role_MICRO1.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_MICRO1_task_st_State27_attach" {
  policy_arn                        = aws_iam_policy.ecs_task_definition_MICRO1_task_st_State27.arn
  role                              = aws_iam_role.task_role_MICRO1.name
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

resource "aws_security_group" "ASG2_group" {
  name                              = "ASG2_group"
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
    "Name" = "ASG2_group"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_Template2" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "Template2" {
  image_id                          = data.aws_ami.AMI_Data_Source_Template2.id
  name                              = "Template2"
  ebs_optimized                     = true
  instance_type                     = "t3.micro"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN CLOUDMAN VARIABLES ---
echo ECS_CLUSTER='ECSCluster' >> /etc/ecs/ecs.config
# --- END CLOUDMAN VARIABLES ---


EOFUData
)
  vpc_security_group_ids            = [aws_security_group.ASG2_group.id]
  iam_instance_profile {
    name                            = aws_iam_instance_profile.profile_ASG2.name
  }
  tags                              = {
    "Name" = "Template2"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_autoscaling_group" "ASG2" {
  name                              = "ASG2"
  capacity_rebalance                = false
  default_cooldown                  = 300
  default_instance_warmup           = 0
  desired_capacity                  = 1
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_grace_period         = 300
  health_check_type                 = "EC2"
  ignore_failed_scaling_activities  = false
  max_instance_lifetime             = 0
  max_size                          = 1
  min_elb_capacity                  = 0
  min_size                          = 1
  protect_from_scale_in             = false
  termination_policies              = ["Default"]
  vpc_zone_identifier               = [aws_subnet.Subnet19.id]
  wait_for_elb_capacity             = 0
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template2.id
  }
  tag {
    key                             = "Name"
    propagate_at_launch             = true
    value                           = "ASG2"
  }
  tag {
    key                             = "State"
    propagate_at_launch             = true
    value                           = "State27"
  }
  tag {
    key                             = "CloudmanUser"
    propagate_at_launch             = true
    value                           = "GlobalUserName"
  }
}

resource "aws_ecs_capacity_provider" "CapacityProvider" {
  name                              = "CapacityProvider"
  auto_scaling_group_provider {
    auto_scaling_group_arn          = aws_autoscaling_group.ASG2.arn
    managed_draining                = "ENABLED"
    managed_termination_protection  = "DISABLED"
    managed_scaling {
      instance_warmup_period        = 300
      maximum_scaling_step_size     = 10000
      minimum_scaling_step_size     = 1
      status                        = "ENABLED"
      target_capacity               = 100
    }
  }
  tags                              = {
    "Name" = "CapacityProvider"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_ecs_cluster" "ECSCluster" {
  name                              = "ECSCluster"
  tags                              = {
    "Name" = "ECSCluster"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_ecs_cluster_capacity_providers" "assoc_cp_to_ECSCluster" {
  cluster_name                      = aws_ecs_cluster.ECSCluster.name
  capacity_providers                = [aws_ecs_capacity_provider.CapacityProvider.name]
}

resource "aws_ecs_service" "MICRO1_service" {
  name                              = "MICRO1_service"
  cluster                           = aws_ecs_cluster.ECSCluster.id
  desired_count                     = 1
  enable_ecs_managed_tags           = true
  force_delete                      = true
  propagate_tags                    = "TASK_DEFINITION"
  scheduling_strategy               = "REPLICA"
  task_definition                   = aws_ecs_task_definition.MICRO1.arn
  capacity_provider_strategy {
    base                            = 0
    capacity_provider               = aws_ecs_capacity_provider.CapacityProvider.name
    weight                          = 1
  }
  deployment_circuit_breaker {
    enable                          = false
    rollback                        = false
  }
  deployment_controller {
    type                            = "ECS"
  }
  network_configuration {
    assign_public_ip                = false
    security_groups                 = [aws_security_group.ASG2_group.id]
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
    "image" = "ghcr.io/cloudmanpro/ec2hub-test:65aa31e0802c76be5450f39be241abab20993c77"
    "essential" = true
    "cpu" = 128
    "memory" = 256
    "portMappings" = [{
    "protocol" = "tcp"
    "containerPort" = 80
    "hostPort" = 80
  }, {
    "protocol" = "udp"
    "containerPort" = 2000
    "hostPort" = 2000
  }]
    "privileged" = false
    "readonlyRootFilesystem" = false
    "logConfiguration" = {
    "logDriver" = "awslogs"
    "options" = {
    "awslogs-group" = aws_cloudwatch_log_group.ECSLogs.name
    "awslogs-region" = "us-east-1"
    "awslogs-stream-prefix" = "Container"
  }
  }
  }
  container_def_MICRO1_Container2 = {
    "name" = "Container2"
    "image" = "ghcr.io/ghcr.io/cloudmanpro/ec2hub-test:65aa31e0802c76be5450f39be241abab20993c77"
    "essential" = true
    "cpu" = 129
    "memory" = 256
    "portMappings" = [{
    "protocol" = "tcp"
    "containerPort" = 81
    "hostPort" = 81
  }]
    "privileged" = false
    "readonlyRootFilesystem" = false
    "logConfiguration" = {
    "logDriver" = "awslogs"
    "options" = {
    "awslogs-group" = aws_cloudwatch_log_group.ECSLogs.name
    "awslogs-region" = "us-east-1"
    "awslogs-stream-prefix" = "Container2"
  }
  }
  }
}

resource "aws_ecs_task_definition" "MICRO1" {
  container_definitions             = jsonencode([local.container_def_MICRO1_Container, local.container_def_MICRO1_Container2])
  cpu                               = "512"
  execution_role_arn                = aws_iam_role.execution_role_MICRO1.arn
  family                            = "app"
  ipc_mode                          = "host"
  memory                            = "600"
  network_mode                      = "awsvpc"
  pid_mode                          = "host"
  requires_compatibilities          = ["EC2"]
  task_role_arn                     = aws_iam_role.task_role_MICRO1.arn
  tags                              = {
    "Name" = "MICRO1"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "Queue2" {
  name                              = "Queue2"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags                              = {
    "Name" = "Queue2"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_sns_topic" "Topic4" {
  name                              = "Topic4"
  tags                              = {
    "Name" = "Topic4"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "ECSLogs" {
  name                              = "/aws/ecs/MICRO1"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "ECSLogs"
    "State" = "State27"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: MISC ###

resource "null_resource" "cleanup_ECSCluster" {
  triggers                          = {
    "cluster_name" = "${aws_ecs_cluster.ECSCluster.name}"
  }
  depends_on                        = [aws_ecs_cluster.ECSCluster]
  provisioner "local-exec" {
    command                         = <<EOF

        # ECS Resource Cleanup to prevent Auto Scaling Group (ASG) Deadlock
        # ------------------------------------------------------------------
        # EXPLANATION:
        # When destroying an ECS Cluster backed by an ASG with Capacity Providers, 
        # a deadlock often occurs. The ASG cannot terminate EC2 instances because 
        # ECS "Instance Protection" prevents scale-in while tasks are running. 
        # However, Terraform may try to delete the ASG before the ECS services 
        # have fully drained.
        #
        # This script acts as a safeguard to proactively force-drain services, 
        # stop tasks, and deregister instances. This ensures the ASG is free 
        # to scale down and allows the infrastructure destruction to proceed 
        # without hanging.
        # ------------------------------------------------------------------
        # Uses environment credentials (OIDC/GitHub Actions)

        # Wait briefly to ensure Terraform has initiated the destruction process
        sleep 30
        
        # List and scale down services
        SERVICES=$(aws ecs list-services --cluster ${self.triggers.cluster_name} --region us-east-1 --query "serviceArns[*]" --output text)
        if [ -n "$SERVICES" ] && [ "$SERVICES" != "None" ]; then
            for SERVICE in $SERVICES; do
                echo "Scaling down service: $SERVICE"
                aws ecs update-service --cluster ${self.triggers.cluster_name} --region us-east-1 --service "$SERVICE" --desired-count 0 > /dev/null
            done
            sleep 10
            for SERVICE in $SERVICES; do
                echo "Deleting service: $SERVICE"
                aws ecs delete-service --cluster ${self.triggers.cluster_name} --region us-east-1 --service "$SERVICE" --force > /dev/null
            done
        fi

        # Stop remaining tasks
        TASKS=$(aws ecs list-tasks --cluster ${self.triggers.cluster_name} --region us-east-1 --query "taskArns[*]" --output text)
        if [ -n "$TASKS" ] && [ "$TASKS" != "None" ]; then
            for TASK in $TASKS; do
                echo "Stopping task: $TASK"
                aws ecs stop-task --cluster ${self.triggers.cluster_name} --region us-east-1 --task "$TASK" > /dev/null
            done
        fi

        # Deregister container instances (EC2)
        INSTANCE_ARNS=$(aws ecs list-container-instances --cluster ${self.triggers.cluster_name} --region us-east-1 --query "containerInstanceArns[*]" --output text)
        if [ -n "$INSTANCE_ARNS" ] && [ "$INSTANCE_ARNS" != "None" ]; then
            for INSTANCE_ARN in $INSTANCE_ARNS; do
                echo "Deregistering instance: $INSTANCE_ARN"
                aws ecs deregister-container-instance --cluster ${self.triggers.cluster_name} --region us-east-1 --container-instance "$INSTANCE_ARN" --force > /dev/null
            done
        fi
        
EOF
    interpreter                     = ["/bin/bash", "-c"]
    when                            = "destroy"
  }
}


