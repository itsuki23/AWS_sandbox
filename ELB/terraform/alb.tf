# ------------------------------
# Var
# ------------------------------
# 自分以外の通信を許可する場合はこちらを指定
variable "allowed_cidr" {
  default = null
}

locals {
  prefix     = "..."

  # My cider getting from API
  current-ip = chomp(data.http.ifconfig.body)
  my_cidr    = (var.allowed_cidr == null) ? "${local.current-ip}/32" : var.allowed_cidr
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

# ------------------------------
# Output
# ------------------------------
output "ALB_dns_name" {
  value = aws_lb.public.dns_name
}



# ------------------------------
#  ApplicationLoadBalancer
# ------------------------------

resource "aws_lb" "public" {
  name                       = "${local.prefix}-alb"
  load_balancer_type         = "application"
  idle_timeout               = 60
  internal                   = false  # 内部向け
  enable_deletion_protection = true   # 削除保護
  subnets = [
    data.aws_ssm_parameter.public_subnet_1a_id.value,
    data.aws_ssm_parameter.public_subnet_1c_id.value
  ]
  security_groups = [
    aws_security_group.alb.id
  ]
  access_logs [
    bucket = aws_s3_bucket.alb_log.id # ------------------------------
    enable = true
  ]
}

# ------------------------------
#  Listener + alb + tg
# ------------------------------

# http listener to https
resource "aws_lb_listener" "http_to_https" {
  load_balancer_arn  = aws_lb.public.arn
  port               = "80"
  protocol           = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.public.arn
    redirect {
      port           = "443"
      protocol       = "HTTPS"
      status_code    = "HTTP_301"
    }
  }
}

# https listener
resource "aws_lb_listener" "https" {
  load_balancer_arn  = aws_lb.public.arn
  port               = "443"
  protocol           = "HTTPS"
  ssl_policy         = "ELBSecurityPolicy-2016-08"
  certificate_arn    = aws_acm_certificate.ssl.arn # ------------------------------

  default_action { 
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}



# ------------------------------
#  TargetGroup
# ------------------------------

resource "aws_lb_target_group" "public" {
  name        = "${local.prefix}-tg"
  # target_type = "ip"
  # defaultはインスタンス ipに設定するとattachmentのtarget_idでエラー
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path                = "/"
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  depends_on = [aws_lb.public]
}



# ------------------------------
#  Attachment TargetGroup + ec2
# ------------------------------

resource "aws_lb_target_group_attachment" "public_1a" {
  target_group_arn = aws_lb_target_group.public.arn
  target_id        = aws_instance.ec2_1a.id # ------------------------------
  port             = 80
}
resource "aws_lb_target_group_attachment" "public_1c" {
  target_group_arn = aws_lb_target_group.public.arn
  target_id        = aws_instance.ec2_1c.id # ------------------------------
  port             = 80
}



# ------------------------------
#  SecurityGroup
# ------------------------------

resource "aws_security_group" "alb" {
  name        = "climb-alb-sg"
  description = "Allow http https"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

