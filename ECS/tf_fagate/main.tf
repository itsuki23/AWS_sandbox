# https://qiita.com/charon/items/20eb2a3d6a199bbac028

locals {
  # Container definition
  nginx_container_definition = <<JSON
[
  {
    "name": "http-server",
    "image": "nginx:1.19.0",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -f localhost || exit 1"
      ],
      "interval": 5
    }
  }
]
  JSON

  apache_container_definition = <<JSON
[
  {
    "name": "http-server",
    "image": "httpd:2.4.43",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "test -e /proc/1"
      ],
      "interval": 5
    }
  }
]
  JSON
}



resource "aws_ecs_cluster" "http_server" {
  name = "http-server-cluster"
}

resource "aws_ecs_task_definition" "http_server" {
  family                   = "http-server-task-definition"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = local.nginx_container_definition
  #container_definitions = local.apache_container_definition
}

resource "aws_ecs_service" "http_server" {
  name             = "http-server-service"
  cluster          = aws_ecs_cluster.http_server.arn
  task_definition  = aws_ecs_task_definition.http_server.arn
  desired_count    = 5
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  deployment_minimum_healthy_percent = 50

  deployment_controller {
    type = "ECS" # default
    # ローリング更新を行う場合、deployment_controllerのtypeはECSにする必要がある
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = local.ecs_service_security_groups
    subnets          = local.private_subnets
  }

  load_balancer {
    target_group_arn = local.load_balancer_target_group_arn
    container_name   = "http-server"
    container_port   = 80
  }
}