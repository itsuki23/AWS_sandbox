locals {
  prefix = "myk-ecs-training"
}

module "global_params" {
  source = "../modules/data_only_modules"
}