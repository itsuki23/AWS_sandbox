# ------------------------------
# Bastion
# ------------------------------
resource "aws_instance" "bastion" {
  key_name                = local.pem_key
  ami                     = "ami-0af1df87db7b650f4"
  instance_type           = "t2.micro"
  availability_zone       = "ap-northeast-1a"
  subnet_id               = aws_subnet.maintenance_1a.id
  security_groups         = [module.bastion_ssh_sg.security_group.id]
  private_ip              = local.bastion_local_ip
  ebs_optimized           = false
  monitoring              = false
  source_dest_check       = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    "Name"    = "${local.prefix}-bstion-ec2"
    "Project" =    local.prefix
  }
}


