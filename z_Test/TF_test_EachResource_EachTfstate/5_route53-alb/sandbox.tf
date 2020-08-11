




# resource "aws_route53_record" "prod_env_cdn_A" {
#   zone_id = "${aws_route53_zone.zone_for_prod.zone_id}"
#   name    = "img.${aws_route53_zone.zone_for_prod.name}"
#   type    = "A"

#   alias {
#     name                   = "${aws_cloudfront_distribution.cdn.domain_name}"
#     zone_id                = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
#     evaluate_target_health = false
#   }
# }
# resource "aws_route53_record" "prod_env_mail_A" {
#   zone_id = "${aws_route53_zone.zone_for_prod.zone_id}"
#   name    = "mail.${aws_route53_zone.zone_for_prod.name}"
#   type    = "A"
#   records = [
#     "***.***.***.***"
#   ]
#   ttl = 300
# }



# # ------------------------------
# #  ApplicationLoadBalancer
# # ------------------------------

# resource "aws_lb" "public" {
#   name                       = "climb-alb"
#   load_balancer_type         = "application"
#   idle_timeout               = 60
#   internal                   = false
#   enable_deletion_protection = false
#   subnets = [
#     aws_subnet.public_1a.id,
#     aws_subnet.public_1c.id
#   ]
#   security_groups = [aws_security_group.alb.id]
# }
# output "ALB_dns_name" {
#   value = aws_lb.public.dns_name
# }



# # ------------------------------
# #  Listener + alb + tg
# # ------------------------------

# # http listener to https
# resource "aws_lb_listener" "http_to_https" {
#   load_balancer_arn  = aws_lb.public.arn
#   port               = "80"
#   protocol           = "HTTP"

#   default_action {
#     type             = "redirect"
#     target_group_arn = aws_lb_target_group.public.arn
#     redirect {
#       port           = "443"
#       protocol       = "HTTPS"
#       status_code    = "HTTP_301"
#     }
#   }
# }

# # https listener
# resource "aws_lb_listener" "https" {
#   load_balancer_arn  = aws_lb.public.arn
#   port               = "443"
#   protocol           = "HTTPS"
#   ssl_policy         = "ELBSecurityPolicy-2016-08"
#   certificate_arn    = aws_acm_certificate.ssl.arn

#   default_action { 
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.public.arn
#   }
# }



# # ------------------------------
# #  TargetGroup
# # ------------------------------

# resource "aws_lb_target_group" "public" {
#   name        = "climb-alb-tg"
#   # target_type = "ip"
#   # defaultはインスタンス ipに設定するとattachmentのtarget_idでエラー
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.public.id

#   health_check {
#     path                = "/"
#     timeout             = 5
#     interval            = 30
#     matcher             = 200
#     port                = 80
#     protocol            = "HTTP"
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#   }
#   depends_on = [aws_lb.public]
# }



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



# # ------------------------------
# #  SecurityGroup
# # ------------------------------

# resource "aws_security_group" "alb" {
#   name        = "climb-alb-sg"
#   description = "Allow http https"
#   vpc_id      = aws_vpc.public.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# # s3 cloudfroont
# resource "aws_s3_bucket" "b" {
#   bucket = "${var.product_name}"
# }

# resource "aws_s3_bucket_policy" "b" {
#   bucket = "${aws_s3_bucket.b.id}"
#   policy = jsonencode(
#     {
#       Id = "PolicyForCloudFrontPrivateContent"
#       Statement = [
#         {
#           Action = "s3:GetObject"
#           Effect = "Allow"
#           Principal = {
#             AWS = "${aws_cloudfront_origin_access_identity.origin_access.iam_arn}"
#           }
#           Resource = "${aws_s3_bucket.b.arn}/*"
#           Sid      = "1"
#         },
#       ]
#       Version = "2008-10-17"
#     }
#   )
# }













# # Hostzone data
# data "aws_route53_zone" "example" {
#   name = "...com"
# }

# # Hostzone create
# resource "aws_route53_zone" "test_example" {
#   name = local.domain
# }

# # DNS record
# resource "aws_route53_record" "example" {
#   zone_id = data.aws_route53_zone.example.zone_id
#   name    = data.aws_route53_zone.example.com
#   type    = "A"

#   alias {
#     name                   = aws_lb.example.dns_name
#     zone_id                = aws_lb.example.zone_id
#     evaluate_target_health = true
#   }
# }

# output "domain_name" {
#   value = aws_route53_record.example.name
# }


# resource "aws_acm_certificate" "example" {
#   domain_name               = aws_route53_record.example.name
#   subject_alternative_names = []
#   validation_method         = "DNS"
#   lifecycle {
#     create_before_destroy   = true
#   }
# }








# # S3用のcloudfrontの証明書取るときに使います。
# provider "aws" {
#   alias  = "virginia"
#   region = "us-east-1"
# }
# # Route53などへ設定する値に使います。
# variable domain {
#   default = "anken.co.jp"
# }