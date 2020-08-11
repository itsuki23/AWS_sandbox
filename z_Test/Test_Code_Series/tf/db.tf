# ------------------------------
# KMS
# ------------------------------
# Customer Master Key
resource "aws_kms_key" "main" {
  description             = "main Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

# Aliace
resource "aws_kms_alias" "main" {
  name = "alias/main"  # Aliace must named「alias/...」
  target_key_id = aws_kms_key.main.key_id
}

# ------------------------------
# Create Password & put SSM
# ------------------------------
# Create Ramdom Password <only once>
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#()-[]<>"    # "_%@"
}
# Put Password <encrypt>
resource "aws_ssm_parameter" "db_password" {
  name             = "/myk/db/password"
  type             = "SecureString"
  value            = random_password.db_password.result
}
# Get Password
data "aws_ssm_parameter" "db_password" {
  depends_on      = [ aws_ssm_parameter.db_password ]
  name            = "/myk/db/password"
  with_decryption = true
}

# ------------------------------
# RDS Instance
# ------------------------------
resource "aws_db_instance" "rds" {
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
  name                       = local.db_name
  username                   = local.db_username
  password                   = data.aws_ssm_parameter.db_password.value
  parameter_group_name       = "default.mysql8.0"
  auto_minor_version_upgrade = true
  availability_zone          = "ap-northeast-1a"
  backup_window              = "17:21-17:51"
  backup_retention_period    = 7
  maintenance_window         = "mon:10:10-mon:10:40"
  vpc_security_group_ids     = [module.mysql_sg.security_group.id]
  db_subnet_group_name       = aws_db_subnet_group.rds.name
  deletion_protection        = false

  depends_on = [
    module.mysql_sg,
    aws_db_subnet_group.rds,
    data.aws_ssm_parameter.db_password,
  ]
  tags = {
    "Name"    = "${local.prefix}-db-rds"
    "Project" =    local.prefix
  }
}
# db_password: random_password生成 -> ssm_put -> rds定義の順
# この順番なら、値が違うときにエラーが出る
# × ramdom_password.db_password.result

# ------------------------------
# DB_SubnetGroup
# ------------------------------
resource "aws_db_subnet_group" "rds" {
  name = "${local.prefix}_rds_subnet_group"
  description = "subnet_group_for_rds"
  subnet_ids = [
    aws_subnet.db_1a.id,
    aws_subnet.db_1c.id
  ]
}
