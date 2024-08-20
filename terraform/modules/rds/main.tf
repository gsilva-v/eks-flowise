module "db_default" {
  source = "terraform-aws-modules/rds/aws"

  # identifier                     = "testdbtoolz"
  # instance_use_identifier_prefix = true

  # create_db_option_group    = false
  # create_db_parameter_group = false

  # engine               = "postgres"
  # engine_version       = "14"
  # family               = "postgres14" # DB parameter group
  # major_engine_version = "14"         # DB option group
  # instance_class       = "db.t4g.micro"

  # allocated_storage = 20

  # db_name  = "admin"
  # username = "admin"
  # port     = 5432

  # db_subnet_group_name   = aws_db_subnet_group.main.name
  # vpc_security_group_ids = [aws_security_group.web_sg.id]

  # maintenance_window      = "Mon:00:00-Mon:03:00"
  # backup_window           = "03:00-06:00"
  # backup_retention_period = 0

  identifier = var.identifier
  instance_use_identifier_prefix = var.instance_use_identifier_prefix

  create_db_option_group = var.create_db_option_group
  create_db_parameter_group = var.create_db_parameter_group

  engine = var.engine
  engine_version = var.engine_version
  family = var.family
  major_engine_version = var.major_engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage

  db_name = var.db_name
  username = var.username
  port = var.port

  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  
  maintenance_window = var.maintenance_window
  backup_window = var.backup_window
  backup_retention_period = var.backup_retention_period
  

}
