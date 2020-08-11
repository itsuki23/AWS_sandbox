locals {
  prefix   = "myk-test01"

  # main side
  vpc_cidr = "10.0.0.0/16"

  # for bastion, nat-gateway, ELB
  public_subnet_1a_cidr  = "10.0.10.0/24"
  public_subnet_1c_cidr  = "10.0.20.0/24"

  # for ec2, fagate, elastic-cache, rds
  private_sublet_1a_cidr = "10.0.11.0/24"
  private_subnet_1c_cidr = "10.0.21.0/24"
}