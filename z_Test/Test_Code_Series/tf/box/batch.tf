# ------------------------------
# task for batch
# ------------------------------
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

  execution_role_arn = module.ecs_task_execution_role.iam_role_arn # for Log
}

# ------------------------------
# cloud watch
# ------------------------------
# Cloud Watch Logs
resource "aws_cloudwatch_log_group" "for_ecs_scheduled_tasks" {
  name              = "/ecs-scheduled-tasks/main"
  retention_in_days = 180
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
      subnets           = [module.params.network.private_subnet_1a.id]
    }
  }
}

# ------------------------------
# IAM role
# ------------------------------
# get IAM policy managed by aws  ★1
data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}
# define overwrited iam policy
module "ecs_events_role" {
  source     = "../modules/iam_role"
  name       = "ecs-events"
  identifier = "events.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_events_role_policy.policy  # ★1
}