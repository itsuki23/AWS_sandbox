# ------------------------------
# ECS
# ------------------------------
# Cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-ecs-cluster"
}



# Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${local.prefix}-task" # :n (revision nunber)
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<JSON
[
  {
    "name": "nginx",
    "image": "nginx:1.19.0",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "nginx",
        "awslogs-group": "/ecs/main"
      }
    }
  }
]
JSON

  # for container log
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}



# Service
resource "aws_ecs_service" "main" {
  name                              = "${local.prefix}-ecs-service"
  cluster                           = aws_ecs_cluster.main.arn
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false # fargate_instanceはprivate_subnetの中
    security_groups = [module.nginx_sg.security_group.id]

    subnets = [
      module.global_params.private_subnet_1a.id,
      module.global_params.private_subnet_1c.id,
    ]
  }

  load_balancer {
    # target_group_arn = aws_lb_target_group.public.arn # --------------alb id
    target_group_arn = module.global_params.alb_tg.arn
    container_name   = "nginx"  # -> container_definitions.EOF.name
    container_port   = 80
  }

  lifecycle {
    ignore_changes   = [task_definition]
  }
}



# SG
module "nginx_sg" {
  source      = "../modules/security_group"
  name        = "nginx-sg"
  vpc_id      = module.global_params.vpc.id
  port        = 80
  cidr_blocks = [module.global_params.vpc.cidr_block]
}






# ------------------------------
# LOG
# ------------------------------
# cloud watch
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/main" 
  retention_in_days = 180
}

# get iam policy managed by aws
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

    # get policy document(setting statement)
    data "aws_iam_policy_document" "ecs_task_execution" {
      source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy
      
      statement {
        effect    = "Allow"
        actions   = ["ssm:GetParameter", "kms:Decrypt"]
        resources = ["*"]
      }
    }

        # create iam role
        module "ecs_task_execution_role" {
          source     = "../modules/iam_role"
          name       = "ecs-task-execution"
          identifier = "ecs-tasks.amazonaws.com"
          policy     = data.aws_iam_policy_document.ecs_task_execution.json
        }



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
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<JSON
[
  {
    "name": "alpine",
    "image": "alpine:latest",
    "essential": true,

    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "batch",
        "awslogs-group": "/ecs-scheduled-tasks/main"
      }
    },
    "secrets": [
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

  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

# get IAM policy managed by aws
data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}
    # define overwrited iam policy
    module "ecs_events_role" {
      source     = "../modules/iam_role"
      name       = "ecs-events"
      identifier = "events.amazonaws.com"
      policy     = data.aws_iam_policy.ecs_events_role_policy.policy
    }


# Cloud Watch Event Rule
resource "aws_cloudwatch_event_rule" "main_batch" {
  name                = "main-batch"
  description         = "とても重要なバッチです"
  schedule_expression = "cron(*/2 * * * ? *)"
  # https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/services-cloudwatchevents-expressions.html
}

# Cloud Watch Event Target
resource "aws_cloudwatch_event_target" "main_batch" {
  target_id = "main-batch"
  rule      = aws_cloudwatch_event_rule.main_batch.name  # CW rule
  role_arn  = module.ecs_events_role.iam_role_arn        # attach role
  arn       = aws_ecs_cluster.main.arn                   # cluster_arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    platform_version    = "1.3.0"
    task_definition_arn = aws_ecs_task_definition.main_batch.arn
    
    network_configuration {
      assign_public_ip  = "false"
      subnets           = [module.global_params.private_subnet_1a.id]
    }
  }
}

# check
# aws logs filter-log-events --log-group-name /ecs/main
# aws logs filter-log-events --log-group-name /ecs-scheduled-tasks/example
# aws logs tail <aws_cloudwatch_log_group.name{ex /ecs/main}> --follow
# aws elbv2 describe-load-balancers --names <load balancer name>