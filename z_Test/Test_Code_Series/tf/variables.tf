locals {
  prefix = "myk-test"
  domain = "climb-match.work"
  
  # my ip
  home_ip   = data.aws_ssm_parameter.home_ip.value
  office_ip = data.aws_ssm_parameter.office_ip.value

  # network cidr
  vpc_cidr                          = "10.0.0.0/16"

  public_alb_1a_cidr         = "10.0.20.0/24"
  public_alb_1c_cidr         = "10.0.40.0/24"

  public_maintenance_1a_cidr = "10.0.100.0/24"
  public_maintenance_1c_cidr = "10.0.200.0/24"

  private_server_1a_cidr     = "10.0.21.0/24"
  private_server_1c_cidr     = "10.0.41.0/24"

  private_db_1a_cidr         = "10.0.33.0/24"
  private_db_1c_cidr         = "10.0.55.0/24"

  # Bastion private ip
  pem_key          = "miyake-key"
  bastion_local_ip = "10.0.100.100"

  # DB
  db_name     = "myk_test"
  db_username = "root"
}
