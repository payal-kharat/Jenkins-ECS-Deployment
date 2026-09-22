resource "aws_ecs_service" "dev_frontend" {
  name            = "${var.project_name}-dev-frontend-service"
  cluster         = aws_ecs_cluster.dev.id
  task_definition = aws_ecs_task_definition.dev_frontend.arn
  depends_on = [
  aws_ecs_task_definition.dev_backend
]

  desired_count = 1
  launch_type   = "FARGATE"
  service_connect_configuration {
  enabled   = true
  namespace = aws_service_discovery_http_namespace.app1_dev.arn
}

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "dev_backend" {
  name            = "${var.project_name}-dev-backend-service"
  cluster         = aws_ecs_cluster.dev.id
  task_definition = aws_ecs_task_definition.dev_backend.arn
  depends_on = [
  aws_ecs_task_definition.dev_backend
]

  desired_count = 1
  launch_type   = "FARGATE"
  service_connect_configuration {
  enabled   = true
  namespace = aws_service_discovery_http_namespace.app1_dev.arn


  service {
    port_name      = "backend"
    discovery_name = "app1-backend"

    client_alias {
      port = 8000
    }
  }
}

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "dev_db" {
  name            = "${var.project_name}-dev-db-service"
  cluster         = aws_ecs_cluster.dev.id
  task_definition = aws_ecs_task_definition.dev_db.arn
  depends_on = [
  aws_ecs_task_definition.dev_db
]

  desired_count = 1
  launch_type   = "FARGATE"
  service_connect_configuration {
  enabled   = true
  namespace = aws_service_discovery_http_namespace.app1_dev.arn


  service {
    port_name      = "mysql"
    discovery_name = "app1-db"

    client_alias {
      port = 3306
    }
  }
}

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  
}