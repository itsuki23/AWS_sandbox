# ------------------------------
# Import IP
# ------------------------------
data "aws_ssm_parameter" "home_ip" {
  name  = "/myk/ip/home"
}

data "aws_ssm_parameter" "office_ip" {
  name  = "/myk/ip/office"
}

# ------------------------------
# Security Group
# ------------------------------
# EC2_Bastion
module "bastion_ssh_sg" {
  source      = "../modules/sg"
  name        = "bastion-ssh-sg"
  vpc_id      = aws_vpc.main.id
  port        = 22
  cidr_blocks = [
    "${local.home_ip}/32",
    "${local.office_ip}/32"
  ]
}

# # ALB https
# module "alb_https_sg" {
#   source      = "../modules/sg"
#   name        = "alb-https-sg"
#   vpc_id      = aws_vpc.main.id
#   port        = 443
#   cidr_blocks = ["0.0.0.0/0"]
# }

# # ALB http redirect
# module "alb_http_redirect_sg" {
#   source      = "../modules/sg"
#   name        = "alb-http-redirect-sg"
#   vpc_id      = aws_vpc.main.id
#   port        = 8080
#   cidr_blocks = ["0.0.0.0/0"]
# }

# ALB http
module "alb_http_sg" {
  source      = "../modules/sg"
  name        = "abl-http-sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = [
    "${local.home_ip}/32",
    "${local.office_ip}/32"
  ]
}
# EC2 Server
module "server_http_sg" {
  source      = "../modules/sg"
  name        = "server-http-sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = [module.alb_http_sg.security_group.id]
}

# db
module "mysql_sg" {
  source      = "../modules/sg"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.main.id
  port        = 3306
  cidr_blocks = [module.server_http_sg.security_group.id]  # tmp
}

# # ECS_EC2_Container
# module "nginx_sg" {
#   source      = "../modules/sg"
#   name        = "nginx-sg"
#   vpc_id      = aws_vpc.main.id
#   port        = 80
#   cidr_blocks = [local.vpc_cidr]
# }