resource "aws_instance" "web" {
  ami           = "ami-066784287e358dad1" 
  # ami           = "ami-066784287e358dad1" 
  # instance_type = "t2.micro"
  instance_type = var.instance-type
  subnet_id     = var.subnet-id 
  # subnet_id     = aws_subnet.public[0].id 
  # vpc_security_group_ids = [aws_security_group.web_sg.id]
  vpc_security_group_ids = var.vpc-security-group-ids
}