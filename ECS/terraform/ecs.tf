# After create vpc-subnet, rds
# ------------------------------
# Var
# ------------------------------
# 自分以外の通信を許可する場合はこちらを指定
variable "allowed_cidr" {
  default = null
}

locals {
  prefix = ""
  # pem_key      = "miyake-key"

  # My cider getting from API
  current-ip   = chomp(data.http.ifconfig.body)
  my_cidr      = (var.allowed_cidr == null) ? "${local.current-ip}/32" : var.allowed_cidr

  nginx_container_definition = <<JSON
[
  {
    "name": "example",
    "image": "nginx:1.19.0",
    "essential": true,

    "logConfiguration": {
      "logDriver": "awslogs",
      "option": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "nginx",
        "awslogs-group": "/ecs/example"
      }
    },
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80
      }
    ]
  }
]
  JSON


  batch_container_definition = <<JSON
[
  {
    "name": "alpine",
    "image": "alpine:latest",
    "essential": true,

    "logConfiguration": {
      "logDriver": "awslogs",
      "option": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "batch",
        "awslogs-group": "/ecs-scheduled-tasks/example"
      }
    },
    "secret": [
      {
        "name": "DB_USERNAME",
        "valueFrom": "/rds/db_username"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "rds/db_password"
      }
    ],
    "command": ["/usr/bin/env"]
  }
]
  JSON
}


# ------------------------------
# Data
# ------------------------------
data "aws_ssm_parameter" "private_subnet_1a_id" {
    name  = "/${local.vpc_prefix}/private_subnet_1a_id"
}
data "aws_ssm_parameter" "private_subnet_1c_id" {
    name  = "/${local.vpc_prefix}/private_subnet_1c_id"
}

# ------------------------------
# ECS
# ------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-ecs-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${local.prefix}-task-difinition" # :n (revision nunber)
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["Fagate"]
  container_definitions    = local.nginx_container_definition
  # for container log
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "main" {
  name                              = "${local.prefix}-ecs-service"
  cluster                           = aws_ecs_cluster.main.arn
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = 2
  launch_type                       = "FAGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false # fagate_instanceはprivate_subnetの中
    security_groups = [aws_security_group.ecs.id]

    subnets = [
      data.aws_ssm_parameter.private_subnet_1a_id.value,
      data.aws_ssm_parameter.private_subnet_1c_id.value
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.public.arn
    container_name   = "main" # ------------------------------
    container_port   = 80
  }

  lifecycle {
    ignore_changes   = [task_definition]
  }
}

# ------------------------------
# Securty Group
# ------------------------------
# SG
resource "aws_security_group" "ecs" {
  name        = "${local.vpc_prefix}-ecs-sg"
  description = "Allow ssh bastion"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}

# in ssh
resource "aws_security_group_rule" "ecs_allow_in_ssh" {
  security_group_id = aws_security_group.ecs.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}

# out all
resource "aws_security_group_rule" "ecs_allow_out_all" {
  security_group_id = aws_security_group.ecs.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------------
# ALB Target Group
# ------------------------------
resource "aws_lb_target_group" "public" {
  name        = "${local.prefix}-tg"
  # target_type = "ip"
  # defaultはインスタンス ipに設定するとattachmentのtarget_idでエラー
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path                = "/"
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  depends_on = [aws_lb.public]
}






# LOG
# ------------------------------
# Cloud Watch Logs
# ------------------------------
# cloud watch
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/main"
  retention_in_days = 180
}

# policy managed aws
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# policy document
data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy
  
  statement {
    effect    = "Allow"
    action    = ["ssm:GetParameter", "kms:Decrypt"]
    resources = ["*"]
  }
}

# IAM role
module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazon.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

# check
# $ aws logs filter-log-events --log-group-name /ecs/main


# ------------------------------
# Batch
# ------------------------------
# Cloud Watch Logs
resource "aws_cloudwatch_log_group" "for_ecs_scheduled_tasks" {
  name              = "/ecs-scheduled-tasks/main"
  retention_in_days = 180
}

# task define
resource "aws_ecs_task_definition" "main_batch" {
  family                   = "main-batch"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FAGATE"]
  contaienr_definitions    = local.batch_container_definition
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

# IAM role define
module "ecs_events_role" {
  source = "./iam_role"
  name = "ecs-evnets"
  identifier = "events.amazonaws.com"
  policy = data.aws_iam_policy.ecs_events_role_policy.policy
}
data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEvnetsRole"
}

# Cloud Watch Event Rule
resource "aws_cloudwatch_event_rule" "example_batch" {
  name = "example-batch"
  description = "とても重要なバッチです"
  schedule_expression = "cron(*/2***? *)"
  # https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/services-cloudwatchevents-expressions.html
}

# Cloud Watch Event Target
resource "aws_cloudwatch_event_target" "example_batch" {
  target_id = "example-batch"
  rule      = aws_cloudwatch_event_rule.example_batch.name
  role_arn  = module.ecs__events_role.iam_role_arn
  arn       = aws_ecs_cluster.example.arn

  ecs_target { 
    launch_type         = "FAGATE"
    task_count          = 1
    platform_version    = "1.3.0"
    task_definition_arn = "aws_ecs_task_definition.example_batch.arn"
    
    network_configuration {
      assign_public_ip  = "false"
      subnets           = [data.aws_ssm_parameter.private_subnet_1a_id.value]
    }
  }
}

# check
# aws logs filter-log-events --log-group-name /ecs-scheduled-tasks/example