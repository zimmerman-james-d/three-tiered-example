output "private_subnets" {
  value = aws_subnet.terraform_private_subnet
}

output "public_subnets" {
  value = aws_subnet.terraform_public_subnet
}
