locals {
  cloudwatch_environments = ["dev", "qa", "uat", "prod"]
  cloudwatch_services     = ["backend", "frontend", "db"]

  app_log_groups = {
    for item in flatten([
      for env in local.cloudwatch_environments : [
        for service in local.cloudwatch_services : {
          key         = "${env}-${service}"
          name        = "/ecs/${var.project_name}-${env}-${service}"
          environment = env
          service     = service
        }
      ]
    ]) : item.key => item
  }
}

resource "aws_cloudwatch_log_group" "app" {
  for_each = local.app_log_groups

  name              = each.value.name
  retention_in_days = 7

  tags = {
    Project     = var.project_name
    Application = var.project_name
    Environment = each.value.environment
    Service     = each.value.service
  }
}
