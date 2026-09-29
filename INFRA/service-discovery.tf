resource "aws_service_discovery_http_namespace" "app3_dev" {
  name = "${var.project_name}-dev"
}

resource "aws_service_discovery_http_namespace" "app3_qa" {
  name = "${var.project_name}-qa"
}

resource "aws_service_discovery_http_namespace" "app3_uat" {
  name = "${var.project_name}-uat"
}

resource "aws_service_discovery_http_namespace" "app3_prod" {
  name = "${var.project_name}-prod"
}
