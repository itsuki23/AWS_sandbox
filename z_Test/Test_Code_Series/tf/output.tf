# ------------------------------
# Output
# ------------------------------
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "ALB_dns_name" {
  value = aws_lb.public.dns_name
}

# output "domain_name" {
#   value = aws_route53_record.domain.name
# }

output "RDS_end_point" {
  value = aws_db_instance.rds.endpoint
}

# ECS check
# aws logs filter-log-events --log-group-name /ecs/main
# aws logs filter-log-events --log-group-name /ecs-scheduled-tasks/example
# aws logs tail <aws_cloudwatch_log_group.name{ex /ecs/main}> --follow
# aws elbv2 describe-load-balancers --names <load balancer name>