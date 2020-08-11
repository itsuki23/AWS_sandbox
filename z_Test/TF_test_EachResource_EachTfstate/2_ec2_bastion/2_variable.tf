# ------------------------------
# Var
# ------------------------------
# 自分以外の通信を許可する場合はこちらを指定
variable "allowed_cidr" {
  default = null
}

locals {
  prefix       = "ecs-training"
  vpc_prefix   = "myk-main"
  pem_key      = "miyake-key"

  # My cider getting from API
  current-ip   = chomp(data.http.ifconfig.body)
  my_cidr      = (var.allowed_cidr == null) ? "${local.current-ip}/32" : var.allowed_cidr

  bastion_ip   = "10.10.10.10"
  bastion_cidr = "10.10.10.10/32"
}

module "global_params" {
  source = "../modules/data_only_modules"
}