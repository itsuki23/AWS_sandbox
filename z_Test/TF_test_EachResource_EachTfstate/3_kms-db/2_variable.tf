locals {
  prefix      = "ecs-training"
  db_name     = "ecs_training"
  db_username = "root"
}

module "global_params" {
  source = "../modules/data_only_modules"
}