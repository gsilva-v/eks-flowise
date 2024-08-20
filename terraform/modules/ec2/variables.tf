variable "ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
}

variable "instance-type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

variable "subnet-id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}

variable "vpc-security-group-ids" {
  description = "The security group IDs to associate with the instance"
  type        = list(string)
}