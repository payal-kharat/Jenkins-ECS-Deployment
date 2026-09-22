resource "aws_ecs_task_definition" "dev_backend" {
  family                   = "${var.project_name}-dev-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "python:3.10-alpine"
      essential = true

      portMappings = [
        {
          name          = "backend"
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = data.aws_secretsmanager_secret.db_password.arn
        }
      ]

      environment = [
        {
          name  = "FLASK_APP"
          value = "hello.py"
        },
        {
          name  = "FLASK_ENV"
          value = "development"
        },
        {
          name  = "FLASK_RUN_PORT"
          value = "8000"
        },
        {
          name  = "FLASK_RUN_HOST"
          value = "0.0.0.0"
        }
      ]
    }
  ])
}