# Var
output "prefix" {
  value = local.prefix
}
output "vpc_cidr" {
  value = local.vpc_cidr
}
output "public_subnet_1a_cidr" {
  value = local.public_subnet_1a_cidr
}
output "public_subnet_1c_cidr" {
  value = local.public_subnet_1c_cidr
}
output "private_subnet_1a_cidr" {
  value = local.private_subnet_1a_cidr
}
output "private_subnet_1c_cidr" {
  value = local.private_subnet_1c_cidr
}

# VPC
output "vpc_id" {
  value = aws_vpc.main.id
}

# Subnet
output "public_subnet_1a_id" {
  value = aws_subnet.public_1a.id
}
output "public_subnet_1c_id" {
  value = aws_subnet.public_1c.id
}
output "private_subnet_1a_id" {
  value = aws_private.public_1a.id
}
output "private_subnet_1c_id" {
  value = aws_subnet.private_1c.id
}

