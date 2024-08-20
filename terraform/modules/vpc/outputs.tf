output "vpc_id" {
  value = aws_vpc.main.id
  
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_default_security_group_id" {
  value = aws_vpc.main.default_security_group_id
}

output "vpc_default_route_table_id" {
  value = aws_vpc.main.default_route_table_id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
  
}