output "ALB_dns_name" {
  value = aws_lb.public.dns_name
}

output "domain_name" {
  value = aws_route53_record.domain.name
}
# curl http://**** で確認