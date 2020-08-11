# for all
locals { prefix = "myk-main" }



data "aws_vpc"    "main"       { tags = { Name = "${local.prefix}-vpc" } }
data "aws_subnet" "public_1a"  { tags = { Name = "${local.prefix}-public-subnet-1a" } }
data "aws_subnet" "public_1c"  { tags = { Name = "${local.prefix}-public-subnet-1c" } }
data "aws_subnet" "private_1a" { tags = { Name = "${local.prefix}-private-subnet-1a" } }
data "aws_subnet" "private_1c" { tags = { Name = "${local.prefix}-private-subnet-1c" } }



output "vpc"               { value = data.aws_vpc.main }
output "public_subnet_1a"  { value = data.aws_subnet.public_1a }
output "public_subnet_1c"  { value = data.aws_subnet.public_1c }
output "private_subnet_1a" { value = data.aws_subnet.private_1a }
output "private_subnet_1c" { value = data.aws_subnet.private_1c }



# ※jsonで返ってくるので「.id」などを付け加えて使用

# ex) define
# module "global_params" {
#  source = "../module/data_only_modules"
# }

# ex) use
# module.global_params.vpc.id


# locals { elb_prefix = "ecs-training"}

# data "aws_lb_target_group" "public" { tags = { Name = "${local.elb_prefix}-tg" } }

# output "alb_tg" { value = data.aws_lb_target_group.public }