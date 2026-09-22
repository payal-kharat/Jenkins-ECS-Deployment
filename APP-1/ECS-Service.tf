locals {
  service_environments = {
    qa = {
      cluster   = aws_ecs_cluster.qa.id
      namespace = aws_service_discovery_http_namespace.app1_qa.arn
    }

    uat = {
      cluster   = aws_ecs_cluster.uat.id
      namespace = aws_service_discovery_http_namespace.app1_uat.arn
    }

    prod = {
      cluster   = aws_ecs_cluster.prod.id
      namespace = aws_service_discovery_http_namespace.app1_prod.arn
    }
  }
}
resource "aws_ecs_service" "frontend" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-frontend-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.frontend[each.key].arn
  

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_service" "backend" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-backend-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.backend[each.key].arn

  desired_count = 1
  launch_type   = "FARGATE"
  service_connect_configuration {
  enabled   = true
  namespace = each.value.namespace


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

resource "aws_ecs_service" "db" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-db-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.db[each.key].arn

  desired_count = 1
  launch_type   = "FARGATE"
  service_connect_configuration {
  enabled   = true
  namespace = each.value.namespace

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