variable "cluster-name" {
  description = "The name of the EKS cluster"
  type        = string  
}

variable "cluster-version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "subnet-ids" {
  description = "The IDs of the subnets to launch the EKS cluster in"
  type        = list(string)
}

variable "vpc-id" {
  description = "The ID of the VPC to launch the EKS cluster in"
  type        = string
}