locals {
  environments = {
    dev  = aws_ecs_cluster.dev
    qa   = aws_ecs_cluster.qa
    uat  = aws_ecs_cluster.uat
    prod = aws_ecs_cluster.prod
  }
}

resource "aws_ecs_task_definition" "frontend" {
  for_each = local.environments

  family                   = "${var.project_name}-${each.key}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "nginx:1.27-alpine"
      essential = true

      portMappings = [
        {
          name          = "frontend"
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app["${each.key}-frontend"].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  for_each = local.environments

  family                   = "${var.project_name}-${each.key}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

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

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app["${each.key}-backend"].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "db" {
  for_each = local.environments

  family                   = "${var.project_name}-${each.key}-db"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "db"
      image     = "mysql:8.0"
      essential = true

      portMappings = [
        {
          name          = "mysql"
          containerPort = 3306
          hostPort      = 3306
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MYSQL_ROOT_PASSWORD"
          value = var.db_root_password
        },
        {
          name  = "MYSQL_DATABASE"
          value = "appdb"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app["${each.key}-db"].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
