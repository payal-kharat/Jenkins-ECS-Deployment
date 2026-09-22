resource "aws_ecs_task_definition" "dev_frontend" {
  family                   = "${var.project_name}-dev-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "nginx:1.13-alpine"
      essential = true

      portMappings = [
        {
           
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}