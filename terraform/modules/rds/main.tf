module "db_default" {
  source = "terraform-aws-modules/rds/aws"

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
