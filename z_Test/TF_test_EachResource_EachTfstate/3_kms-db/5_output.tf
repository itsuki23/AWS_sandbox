# DB_Username
# Username register parameter_store [not_enctypt]
resource aws_ssm_parameter db_username {
  description      = "データベースのユーザー名"
  name             = "/rds/db_username"
  type             = "String"
  value            = local.db_username
}



# DB_Password
# Ramdom Password [16 characters] 1度だけ
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#()-[]<>"    # "_%@"
}

# Password register parameter_store [encrypt]
resource "aws_ssm_parameter" "db_password" {
  description      = "データベースのパスワード"
  name             = "/rds/db_password"
  type             = "SecureString"
  value            = random_password.db_password.result
}