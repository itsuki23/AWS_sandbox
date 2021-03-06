# # ------------------------------
# # SSM Bastion
# # ------------------------------
# # instance profile
# resource "aws_iam_instance_profile" "ec2_for_ssm" {
#   name = "ec2-for-ssm"
#   role = module.ec2_for_role.iam_role_name
# }

# # create EC2
# resource "aws_instance" "example_for_operation" {
#   ami                  = "ami-0c3fd0f5d33134a76"
#   instance_type        = "t3.micro"
#   iam_instance_profile = aws_iam_instance_profile.ec2_for_ssm.name
#   subnet_id            = aws_subnet.private_0.id # private subnet
#   user_data            = file("./user_data.sh")
# }

# output "operation_instance_id" {
#   value = aws_instance.example_for_operation.id
# }


# # ------------------------------
# # IAM
# # ------------------------------
# # get IAM policy
# data "aws_iam_policy" "ec2_for_ssm" {
#   arn = "arn:aws:iam::policy/AmazonSSMManagedInstanceCore"
# }

# # set IAM policy document
# data "aws_iam_policy_document" "ec2_for_ssm" {
#   source_json = data.aws.iam_policy.ec2_for_ssm.policy

#   statement {
#     effect   = "Allow"
#     resouece = ["*"]

#     action = [
#       "s3:PutObject",
#       "logs:PutLogEvents",
#       "logs:CreateLogStream",
#       "ecr:GetAuthorizationToken",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:GetDownLoadUrlForLayer",
#       "ecr:BatchGetImage",
#       "ssm:GetParameter",
#       "ssm:GetParameters",
#       "ssm:GetParametersByPath",
#       "kms:Decrypt",
#     ]
#   }
# }

# # create IAM role
# module "ec2_for_ssm_role" {
#   source     = "../modules/iam_role"
#   name       = "ec2-for-ssm"
#   identifier = "ec2.amazonaws.com"
#   policy     = data.aws_iam_policy_document.ec2_for_ssm.json
# }


