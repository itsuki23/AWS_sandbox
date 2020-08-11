locals { elb_prefix = "ecs-training"}
data "aws_lb_target_group" "public" { tags = { Name = "${local.elb_prefix}-tg" } }
output "alb_tg" { value = data.aws_lb_target_group.public }