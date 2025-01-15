module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster-name
  cluster_version = var.cluster-version
  subnet_ids      = var.subnet-ids
  vpc_id          = var.vpc-id
}

