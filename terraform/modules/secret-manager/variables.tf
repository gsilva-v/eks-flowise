variable "db_user" {
  description = "The username for the database"
  type        = string
  default = "admin"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default = "password"
}

variable "secret-name" {
  description = "The name of the secret"
  type        = string
}
