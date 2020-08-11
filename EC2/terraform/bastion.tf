# ------------------------------
# Var
# ------------------------------
# 自分以外の通信を許可する場合はこちらを指定
variable "allowed_cidr" {
  default = null
}

locals {
  ec2_prefix   = ""
  vpc_prefix   = "myk-test01"  # vpcのprefix参照
  pem_key      = "miyake-key"

  # My cider getting from API
  current-ip   = chomp(data.http.ifconfig.body)
  my_cidr      = (var.allowed_cidr == null) ? "${local.current-ip}/32" : var.allowed_cidr

  bastion_ip   = 10......
  bastion_cidr = 10....../32
}



# ------------------------------
# Data
# ------------------------------
data "aws_ssm_parameter" "vpc_id" {
    name  = "/${local.vpc_prefix}/vpc_id" 
}
data "aws_ssm_parameter" "public_subnet_1a_id" {
    name  = "/${local.vpc_prefix}/public_subnet_1a_id"
}
data "aws_ssm_parameter" "public_subnet_1c_id" {
    name  = "/${local.vpc_prefix}/public_subnet_1c_id"
}
data "aws_ssm_parameter" "private_subnet_1a_id" {
    name  = "/${local.vpc_prefix}/private_subnet_1a_id"
}
data "aws_ssm_parameter" "private_subnet_1c_id" {
    name  = "/${local.vpc_prefix}/private_subnet_1c_id"
}

# VPC             : data.aws_ssm_parameter.vpc_id.value
# PublicSubnet-1a : data.aws_ssm_parameter.public_subnet_1a_id.value
# PublicSubnet-1c : data.aws_ssm_parameter.public_subnet_1c_id.value
# PrivateSubnet-1a: data.aws_ssm_parameter.Private_subnet_1a_id.value
# PrivateSubnet-1c: data.aws_ssm_parameter.Private_subnet_1c_id.value



# ------------------------------
# EC2
# ------------------------------
resource "aws_instance" "bastion" {
  key_name          = local.pem_key
  ami               = "ami-0af1df87db7b650f4"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  subnet_id         = data.aws_ssm_parameter.Private_subnet_1a_id.value
  security_groups   = [aws_security_group.bastion.id]
  private_ip        = local.bastion_ip
  ebs_optimized     = false
  monitoring        = false
  source_dest_check = false
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  tags = {
    "Name"    = "${local.vpc_prefix}-bstion-ec2"
    "Project" =    local.vpc_prefix
  }
}

# #ElasticIP
# resource "aws_eip" "bastion" {
#   instance     = aws_instance.bastion.id
#   vpc          = true
#   tags = {
#     "Name"     = "${local.vpc_prefix}-bastion-eip"
#     "Project"  =    local.vpc_prefix
#   }
#   # depends_on = [IGW]
# }



# ------------------------------
# Securty Group
# ------------------------------
# SG
resource "aws_security_group" "bastion" {
  name        = "${local.vpc_prefix}-bastion-sg"
  description = "Allow ssh bastion"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}

# in ssh
resource "aws_security_group_rule" "bastion_allow_in_ssh" {
  security_group_id = aws_security_group.server.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}

# out all
resource "aws_security_group_rule" "server_allow_out_all" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}



# ------------------------------
# Parameter Store
# ------------------------------
# Instance
resource "aws_ssm_parameter" "ec2_bastion_id" {
    name  = "/${local.prefix}/ec2_bastion_id"
    value = aws_instance.bastion.id
    type  = "String"
}