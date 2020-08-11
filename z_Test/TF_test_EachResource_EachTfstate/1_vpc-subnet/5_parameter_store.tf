# VPC
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${local.prefix}/vpc_id"
  value = aws_vpc.main.id
  type  = "String"
}

# Subnet
resource "aws_ssm_parameter" "public_subnet_1a_id" {
  name  = "/${local.prefix}/public_subnet_1a_id"
  value = aws_subnet.public_1a.id
  type  = "String"
}
resource "aws_ssm_parameter" "public_subnet_1c_id" {
  name  = "/${local.prefix}/public_subnet_1c_id"
  value = aws_subnet.public_1c.id
  type  = "String"
}
resource "aws_ssm_parameter" "private_subnet_1a_id" {
  name  = "/${local.prefix}/private_subnet_1a_id"
  value = aws_subnet.private_1a.id
  type  = "String"
}
resource "aws_ssm_parameter" "private_subnet_1c_id" {
  name  = "/${local.prefix}/private_subnet_1c_id"
  value = aws_subnet.private_1c.id
  type  = "String"
}