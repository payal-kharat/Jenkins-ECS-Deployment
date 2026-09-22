resource "aws_ecs_task_definition" "dev_db" {
  family                   = "${var.project_name}-dev-db"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "db"
      image     = "mariadb:10-focal"
      essential = true

      portMappings = [
        { name          = "mysql"
          containerPort = 3306
          hostPort      = 3306
          protocol      = "tcp"
        }
      ]

      environment = [
  {
    name  = "MYSQL_DATABASE"
    value = "example"
  },
  {
    name  = "MYSQL_ROOT_PASSWORD_FILE"
    value = "/run/secrets/db-password"
  }
]

secrets = [
  {
    name      = "MYSQL_ROOT_PASSWORD"
    valueFrom = data.aws_secretsmanager_secret.db_password.arn
  }
]
    }
  ])
}