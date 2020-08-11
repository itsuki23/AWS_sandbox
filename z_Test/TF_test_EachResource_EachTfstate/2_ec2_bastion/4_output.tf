# Var
output "prefix" {
  value = local.prefix
}
output "bastion_ip" {
  value = local.bastion_ip
}
output "bastion_cidr" {
  value = local.bastion_cidr
}


# bastion ip
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}