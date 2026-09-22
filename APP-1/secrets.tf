
data "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-db-password"
}