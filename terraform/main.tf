module "vpc" {
  source = "./modules/vpc"
  vpc-name = "main-vpc"
}

module "secret" {
  source = "./modules/secret-manager"
  secret-name = "example-secret-v2"
  db_user = "admin"
  db_password = "password"  
}

module "sg" {
  source = "./modules/sg"
  vpc-id = module.vpc.vpc_id
}

module "eks" {
  source = "./modules/eks"
  cluster-name = "example-eks-cluster"
  cluster-version = "1.30"
  subnet-ids = module.vpc.private_subnet_ids
  vpc-id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"
  identifier = "testdbtoolz"
  instance_use_identifier_prefix = true
  create_db_option_group = false
  create_db_parameter_group = false
  engine = "postgres"
  engine_version = "14"
  family = "postgres14"
  major_engine_version = "14"
  instance_class = "db.t4g.micro"
  allocated_storage = 20
  db_name = "admin"
  username = "admin"
  port = 5432
  db_subnet_group_name = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.sg.sg_id]
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window = "03:00-06:00"
  backup_retention_period = 0
}

# Chamar o módulo ALB
module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_groups = module.sg.sg_id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  origin-id = "example.com"
  cdn-bucket-name = "example-toolz-test"
}