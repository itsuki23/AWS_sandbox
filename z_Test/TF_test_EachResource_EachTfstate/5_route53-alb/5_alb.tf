# ------------------------------
# ALB
# ------------------------------
resource "aws_lb" "public" {
  name                       = "${local.prefix}-alb"
  load_balancer_type         = "application"
  idle_timeout               = 60
  internal                   = false  # 内部向け
  enable_deletion_protection = false  # 削除保護
  subnets = [
    module.global_params.public_subnet_1a.id,
    module.global_params.public_subnet_1c.id,
  ]
  security_groups = [
    module.http_sg.security_group.id,
    module.https_sg.security_group.id,
    module.http_redirect_sg.security_group.id
  ]
  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }
}

# ------------------------------
# SG
# ------------------------------
module "http_sg" {
  source      = "../modules/security_group"
  name        = "http-sg"
  vpc_id      = module.global_params.vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "../modules/security_group"
  name        = "https-sg"
  vpc_id      = module.global_params.vpc.id
  port        = 443
  cidr_blocks = [local.my_cidr]
}

module "http_redirect_sg" {
  source      = "../modules/security_group"
  name        = "http-redirect-sg"
  vpc_id      = module.global_params.vpc.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}



# ------------------------------
#  Listener + alb + tg
# ------------------------------

# http listener to https
resource "aws_lb_listener" "http" {
  load_balancer_arn  = aws_lb.public.arn
  port               = "80"
  protocol           = "HTTP"

  default_action {
    # type           = "fixed-response"
    # fixed_response {
    #   content_type = "text/plain"
    #   message_body = "これは『HTTP』です"
    #   status_code  = "200"
    # }
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
  certificate_arn    = aws_acm_certificate.ssl.arn

  default_action {
    # type           = "fixed-response"
    # fixed_response {
    #   content_type = "text/plain"
    #   message_body = "これは『HTTPS』です"
    #   status_code  = "200"
    # }
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

# http redirect listener
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn  = aws_lb.public.arn
  port               = "8080"
  protocol           = "HTTP"

  default_action {
    type          = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# ------------------------------
#  TargetGroup
# ------------------------------

resource "aws_lb_target_group" "public" {
  name        = "${local.prefix}-tg"
  target_type = "ip"
  # defaultはインスタンス ipに設定するとattachmentのtarget_idでエラー
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.global_params.vpc.id
  # deregistration_delay = 300

  health_check {
    path                = "/"
    timeout             = 5
    interval            = 30
    matcher             = 200
    # port                = 80
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  depends_on = [aws_lb.public]

  tags = {
    Name = "${local.prefix}-tg"
  }
}

# # ------------------------------
# #  Attachment TargetGroup + ec2
# # ------------------------------

# resource "aws_lb_target_group_attachment" "public_1a" {
#   target_group_arn = aws_lb_target_group.public.arn
#   target_id        = aws_instance.ec2_1a.id
#   port             = 80
# }
# resource "aws_lb_target_group_attachment" "public_1c" {
#   target_group_arn = aws_lb_target_group.public.arn
#   target_id        = aws_instance.ec2_1c.id
#   port             = 80
# }
