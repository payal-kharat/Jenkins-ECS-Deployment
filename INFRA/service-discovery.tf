resource "aws_service_discovery_http_namespace" "app1_dev" {
  name = "${var.project_name}-dev"
}

resource "aws_service_discovery_http_namespace" "app1_qa" {
  name = "${var.project_name}-qa"
}

resource "aws_service_discovery_http_namespace" "app1_uat" {
  name = "${var.project_name}-uat"
}

resource "aws_service_discovery_http_namespace" "app1_prod" {
  name = "${var.project_name}-prod"
}
