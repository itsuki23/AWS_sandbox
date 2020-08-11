# ------------------------------
#  Route53
# ------------------------------

# host-zone 参照 (コンソールで作成済み)
data "aws_route53_zone" "host_zone" {
  name = local.domain
}

# host-zone 定義
resource "aws_route53_zone" "host_zone" {
  name = local.domain
}

# dns-record
resource "aws_route53_record" "domain" {
  name    = data.aws_route53_zone.host_zone.name
  zone_id = data.aws_route53_zone.host_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}


# applyでの更新時にroute53 zone(terraform managed)を削除する必要がある
