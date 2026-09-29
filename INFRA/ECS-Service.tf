locals {
  service_environments = {
    dev = {
      cluster   = aws_ecs_cluster.dev.id
      namespace = aws_service_discovery_http_namespace.app3_dev.arn
    }
    qa = {
      cluster   = aws_ecs_cluster.qa.id
      namespace = aws_service_discovery_http_namespace.app3_qa.arn
    }
    uat = {
      cluster   = aws_ecs_cluster.uat.id
      namespace = aws_service_discovery_http_namespace.app3_uat.arn
    }
    prod = {
      cluster   = aws_ecs_cluster.prod.id
      namespace = aws_service_discovery_http_namespace.app3_prod.arn
    }
  }
}

resource "aws_ecs_service" "frontend" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-frontend-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.frontend[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_connect_configuration {
    enabled   = true
    namespace = each.value.namespace
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend[each.key].arn
    container_name   = "frontend"
    container_port   = 80
  }

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [aws_lb_listener.frontend]
}

resource "aws_ecs_service" "backend" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-backend-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.backend[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_connect_configuration {
    enabled   = true
    namespace = each.value.namespace

    service {
      port_name      = "backend"
      discovery_name = "app3-backend"

      client_alias {
        port     = 8080
        dns_name = "app3-backend"
      }
    }
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend[each.key].arn
    container_name   = "backend"
    container_port   = 8080
  }

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [aws_lb_listener_rule.backend_api]
}

resource "aws_ecs_service" "db" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-db-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.db[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  service_connect_configuration {
    enabled   = true
    namespace = each.value.namespace

    service {
      port_name      = "mysql"
      discovery_name = "app3-db"

      client_alias {
        port     = 3306
        dns_name = "app3-db"
      }
    }
  }

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.db.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
