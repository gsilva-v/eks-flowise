output "sg_id" {
  value = aws_security_group.web_sg.id
}

output "acl_id" {
  value = aws_network_acl.main.id
}
