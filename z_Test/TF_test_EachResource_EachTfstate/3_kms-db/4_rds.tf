# ------------------------------
#  RDS
# ------------------------------

resource "aws_db_instance" "rds" {
  depends_on = [
    module.mysql_sg              , aws_db_subnet_group.rds,
    aws_ssm_parameter.db_username, aws_ssm_parameter.db_password,
  ]
  kms_key_id                 = aws_kms_key.main.arn
  storage_encrypted          = true

  multi_az                   = false
  publicly_accessible        = false
  skip_final_snapshot        = true

  identifier                 = "${local.prefix}-rds"
  allocated_storage          = 20
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "8.0.15"
  instance_class             = "db.t2.small"
  name                       = "${local.db_name}"
  # parameter store          = ssm定義 -> rds定義 の順とすることで、値が違うときにエラーが出るようにする
  username                   = aws_ssm_parameter.db_username.value
  password                   = aws_ssm_parameter.db_password.value  # × ramdom_password.db_password.result
  parameter_group_name       = "default.mysql8.0"
  auto_minor_version_upgrade = true
  availability_zone          = "ap-northeast-1a"
  backup_window              = "17:21-17:51"
  backup_retention_period    = 7
  maintenance_window         = "mon:10:10-mon:10:40"
  # vpc_security_group_ids     = [aws_security_group.rds.id]
  vpc_security_group_ids     = [module.mysql_sg.security_group.id]
  db_subnet_group_name       = aws_db_subnet_group.rds.name
  deletion_protection        = false
}
output "RDS_end_point" {
  value = aws_db_instance.rds.endpoint
}



# ------------------------------
#  DB_SubnetGroup
# ------------------------------
resource "aws_db_subnet_group" "rds" {
  name = "${local.prefix}_rds_subnet_group"
  description = "subnet_group_for_rds"
  subnet_ids = [
    "${module.global_params.private_subnet_1a.id}",
    "${module.global_params.private_subnet_1c.id}"
  ]
}


# ------------------------------
#  SecurityGroup
# ------------------------------
module "mysql_sg" {
  source      = "../modules/security_group"
  name        = "mysql_sg"
  vpc_id      = module.global_params.vpc.id
  port        = 3306
  cidr_blocks = [module.global_params.vpc.cidr_block] # ----------------------------仮　ecs security group
}

# resource "aws_security_group" "rds" {
#   name        = "${local.prefix}-rds-sg"
#   description = "Allow only 3306"
#   vpc_id      = aws_vpc.public.id

#   ingress {
#       from_port = 3306
#       to_port = 3306
#       protocol = "tcp"
#       security_groups = [aws_security_group.ec2.id]
#   }
#   egress {
#       from_port = 0
#       to_port = 0
#       protocol = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
# }
