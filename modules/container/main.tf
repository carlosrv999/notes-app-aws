resource "aws_ecs_cluster" "default" {
  name = "ecs-notesapp"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = merge(
    { "Name" = "notes-app" },
    var.tags,
  )
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]
  cluster_name = aws_ecs_cluster.default.name
}

locals {
  port = "8080"
}

resource "aws_ecs_task_definition" "default" {
  container_definitions = jsonencode(
    [
      {
        cpu = 0
        environment = [
          {
            name  = "DATABASE_URL"
            value = "postgresql://notes_user:${urlencode(var.db_password)}@${var.db_endpoint}:5432/notesapp?schema=public"
          },
          {
            name  = "PORT"
            value = "8080"
          },
        ]
        essential = true
        image     = var.container_image
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/notes-webapp"
            awslogs-region        = "us-east-2"
            awslogs-stream-prefix = "ecs"
          }
        }
        mountPoints = []
        name        = "notes-container"
        portMappings = [
          {
            containerPort = local.port
            hostPort      = local.port
            protocol      = "tcp"
          },
        ]
        volumesFrom = []
      },
    ]
  )
  cpu                = "256"
  execution_role_arn = var.task_execution_role_arn
  family             = "notes-webapp"
  memory             = "512"
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]

  runtime_platform {
    operating_system_family = "LINUX"
  }

  tags = merge(
    { "Name" = "notes-app" },
    var.tags,
  )
}

resource "aws_ecs_service" "default" {
  cluster                            = aws_ecs_cluster.default.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  launch_type                        = "FARGATE"
  name                               = "notes-web-app"
  platform_version                   = "LATEST"
  propagate_tags                     = "NONE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = "${aws_ecs_task_definition.default.family}:${aws_ecs_task_definition.default.revision}"

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = var.security_group_ids[*]
    subnets          = var.subnets[*]
  }

  tags = merge(
    { "Name" = "notes-app" },
    var.tags,
  )
}
