output prefix   { value = "myk-test" }

# network
output vpc_cidr               { value = "10.10.0.0/16"  }
output public_subnet_1a_cidr  { value = "10.10.10.0/24" }
output public_subnet_1c_cidr  { value = "10.10.20.0/24" }
output private_subnet_1a_cidr { value = "10.10.11.0/24" }
output private_subnet_1c_cidr { value = "10.10.21.0/24" }

# bastion
output pem_key          { value = "miyake-key"  }
output bastion_local_ip { value = "10.10.10.10" }

# db
output db_name     { value = "ecs_training" }
output db_username { value = "root"         }

# domain
output domain { value = "myk-test.work" }