locals {
  prefix = "myk-main"

  # main side
  vpc_cidr = "10.10.0.0/16"

  # for bastion, nat-gateway, ELB
  public_subnet_1a_cidr = "10.10.10.0/24"
  public_subnet_1c_cidr = "10.10.20.0/24"

  # for ec2, fagate, elastic-cache, rds
  private_subnet_1a_cidr = "10.10.11.0/24"
  private_subnet_1c_cidr = "10.10.21.0/24"
}