variable "identifier" {
  type = string
  default = "testdbtoolz"
}

variable "instance_use_identifier_prefix" {
  type = bool
  default = true
}

variable "create_db_option_group" {
  type = bool
  default = false
}

variable "create_db_parameter_group" {
  type = bool
  default = false
}


variable "engine" {
  type = string
  default = "postgres"
}

variable "engine_version" {
  type = string
  default = "14"
}

variable "family" {
  type = string
  default = "postgres14"
}

variable "major_engine_version" {
  type = string
  default = "14" 
}

variable "instance_class" {
  type = string
  default = "db.t4g.micro"
}


variable "allocated_storage" {
  type = number
  default = 20
}


variable "db_name" {
  type = string
  default = "admin"
}

variable "username" {
  type = string
  default = "admin"
}

variable "port" {
  type = number
  default = 5432
}

variable "db_subnet_group_name" {
  type = string
  default = null
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = null
}

variable "maintenance_window" {
  type = string
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type = string
  default = "03:00-06:00"
}

variable "backup_retention_period" {
  type = number
  default = 0
}
  