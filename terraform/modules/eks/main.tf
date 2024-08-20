module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster-name
  # cluster_name    = "example-eks-cluster"
  # cluster_version = "1.30"
  cluster_version = var.cluster-version
  # subnet_ids         = aws_subnet.private[*].id
  # vpc_id          = aws_vpc.main.id
  subnet_ids      = var.subnet-ids
  vpc_id          = var.vpc-id
}

