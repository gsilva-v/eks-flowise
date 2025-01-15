resource "aws_secretsmanager_secret" "rds_secret" {
  name        = var.secret-name
  description = "RDS credentials"

  tags = {
    Name = var.secret-name
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_user
    password = var.db_password
  })
}