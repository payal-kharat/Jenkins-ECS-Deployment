locals {
  ecr_environments = ["dev", "qa", "uat", "prod"]
  ecr_services     = ["frontend", "backend", "db"]

  ecr_repositories = {
    for item in flatten([
      for env in local.ecr_environments : [
        for service in local.ecr_services : {
          key         = "${env}-${service}"
          name        = "${var.project_name}-${service}-${env}"
          environment = env
          service     = service
        }
      ]
    ]) : item.key => item
  }
}

resource "aws_ecr_repository" "app" {
  for_each = local.ecr_repositories

  name                 = each.value.name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Application = var.project_name
    Environment = each.value.environment
    Service     = each.value.service
  }
}
