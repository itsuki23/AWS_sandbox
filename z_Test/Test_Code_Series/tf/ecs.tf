# ------------------------------
# Cluster
# ------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-ecs-cluster"

  tags = {
    "Name"    = "${local.prefix}-ecs-cluster"
    "Project" =    local.prefix
  }
}

# Service
resource "aws_ecs_service" "main" {
  name                               = "${local.prefix}-ecs-service"
  cluster                            = aws_ecs_cluster.main.arn
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 2
  launch_type                        = "EC2"    # "FARGATE"
  platform_version                   = "1.3.0"
  health_check_grace_period_seconds  = 60
  # deployment_minimum_healthy_percent = 50
  # deployment_maximum_percent         = 100

  deployment_controller {
    type = "ECS"  # default
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.public.arn
    container_name   = "web_server"  # -> container_definitions.EOF.name
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = false # fargate_instanceはprivate_subnetの中
    security_groups = [module.server_http_sg.security_group.id]

    subnets = [
      aws_subnet.server_1a.id,
      aws_subnet.server_1c.id,
    ]
  }

  lifecycle {
    ignore_changes   = [task_definition]  # each_deploy -> update_task_definition -> terraform plan <diff!errior>
  }

  tags = {
    "Name"    = "${local.prefix}-ecs-service"
    "Project" =    local.prefix
  }
}

# ------------------------------
# task for web server
# ------------------------------
resource "aws_ecs_task_definition" "main" {
  family                   = "${local.prefix}-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]    # ["FARGATE"]
  container_definitions    = <<JSON
[
  {
    "name": "web_server",
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
  # execution_role_arn = module.ecs_task_execution_role.iam_role_arn

  tags = {
    "Name"    = "${local.prefix}-ecs-task-definition"
    "Project" =    local.prefix
  }
}
# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_healthcheck

