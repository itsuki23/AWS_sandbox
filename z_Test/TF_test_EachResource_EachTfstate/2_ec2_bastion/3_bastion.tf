# ------------------------------
# EC2
# ------------------------------
resource "aws_instance" "bastion" {
  key_name                = local.pem_key
  ami                     = "ami-0af1df87db7b650f4"
  instance_type           = "t2.micro"
  availability_zone       = "ap-northeast-1a"
  subnet_id               = module.global_params.public_subnet_1a.id
  security_groups         = [module.bastion_sg.security_group.id]
  private_ip              = local.bastion_ip
  ebs_optimized           = false
  monitoring              = false
  source_dest_check       = false
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



# ------------------------------
# SG
# ------------------------------
module "bastion_sg" {
  source      = "../modules/security_group"
  name        = "bastion_sg"
  vpc_id      = module.global_params.vpc.id
  port        = 22
  cidr_blocks = [local.my_cidr]
}