# ------------------------------
# ALB
# ------------------------------
resource "aws_lb" "public" {
  name                       = "${local.prefix}-alb"
  load_balancer_type         = "application"
  idle_timeout               = 60
  internal                   = false  # 内部向けかどうか
  enable_deletion_protection = false  # 削除保護
  subnets = [
    aws_subnet.alb_1a.id,
    aws_subnet.alb_1c.id,
  ]
  security_groups = [
    module.alb_http_sg.security_group.id,
    # module.alb_https_sg.security_group.id,
    # module.alb_http_redirect_sg.security_group.id
  ]
  # access_logs {
  #   bucket  = aws_s3_bucket.alb_log.id
  #   enabled = true
  # }
  tags = {
    Name    = "${local.prefix}-alb"
    Project =    local.prefix
  }
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
    # for test
    type           = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これは『HTTP』です"
      status_code  = "200"
    }

    # # for production
    # type             = "redirect"
    # target_group_arn = aws_lb_target_group.public.arn
    # redirect {
    #   port           = "443"
    #   protocol       = "HTTPS"
    #   status_code    = "HTTP_301"
    # }
  }
}

# # https listener
# resource "aws_lb_listener" "https" {
#   load_balancer_arn  = aws_lb.public.arn
#   port               = "443"
#   protocol           = "HTTPS"
#   ssl_policy         = "ELBSecurityPolicy-2016-08"
#   certificate_arn    = aws_acm_certificate.ssl.arn

#   default_action {
#     # for test
#     # type           = "fixed-response"
#     # fixed_response {
#     #   content_type = "text/plain"
#     #   message_body = "これは『HTTPS』です"
#     #   status_code  = "200"
#     # }

#     # for production
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.public.arn
#   }
# }

# # http redirect listener
# resource "aws_lb_listener" "redirect_http_to_https" {
#   load_balancer_arn  = aws_lb.public.arn
#   port               = "8080"
#   protocol           = "HTTP"

#   default_action {
#     type          = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# ------------------------------
#  TargetGroup
# ------------------------------
resource "aws_lb_target_group" "public" {
  name        = "${local.prefix}-alb-tg"
  target_type = "ip"  # default:instance ipに設定するとattachmentのtarget_idでエラー
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  # deregistration_delay = 300

  health_check {
    path                = "/"
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  # port = "traffic-port" => default: 疎通できるportに通す
  # ECSでは固定ポートを指定すると動的なポート（Ephemeral port）に通信がいかない

  depends_on = [aws_lb.public]

  tags = {
    Name    = "${local.prefix}-alb-tg"
    Project =    local.prefix
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
