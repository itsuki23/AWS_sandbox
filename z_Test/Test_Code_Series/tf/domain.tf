# # ------------------------------
# #  ACM  SSL Certification
# # ------------------------------
# # SSL証明書
# resource "aws_acm_certificate" "ssl" {
#   domain_name               = aws_route53_record.domain.name  # Domain
#   subject_alternative_names = []
#   validation_method         = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # 検証用DNSレコード
# resource "aws_route53_record" "check_ssl" {
#   name    = aws_acm_certificate.ssl.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.ssl.domain_validation_options[0].resource_record_type
#   records = [aws_acm_certificate.ssl.domain_validation_options[0].resource_record_value]
#   zone_id = data.aws_route53_zone.host_zone.id
#   ttl     = "60"
# }

# # 検証の待機
# resource "aws_acm_certificate_validation" "ssl" {
#   certificate_arn = aws_acm_certificate.ssl.arn
#   validation_record_fqdns = [aws_route53_record.check_ssl.fqdn]
# }

# # ------------------------------
# #  Route 53
# # ------------------------------
# # host-zone 参照 (コンソールで作成済み)
# data "aws_route53_zone" "host_zone" {
#   name = local.domain
# }

# # host-zone 定義
# resource "aws_route53_zone" "host_zone" {
#   name = local.domain
# }

# # dns-record
# resource "aws_route53_record" "domain" {
#   name    = data.aws_route53_zone.host_zone.name
#   zone_id = data.aws_route53_zone.host_zone.zone_id
#   type    = "A"
#   alias {
#     name                   = aws_lb.public.dns_name
#     zone_id                = aws_lb.public.zone_id
#     evaluate_target_health = true
#   }
# }

# # applyでの更新時にroute53 zone(terraform managed)を削除する必要がある
