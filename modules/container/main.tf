resource "aws_ecs_task_definition" "example" {
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
            containerPort = 8080
            hostPort      = 8080
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
}

resource "aws_ecs_service" "imported" {
  cluster                            = "arn:aws:ecs:us-east-2:452034299452:cluster/notesapp"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  iam_role                           = "aws-service-role"
  launch_type                        = "FARGATE"
  name                               = "notes-web-app"
  platform_version                   = "LATEST"
  propagate_tags                     = "NONE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = "notes-webapp:2"

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

  timeouts {}
}
