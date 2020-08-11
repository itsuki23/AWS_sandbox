# Prefix
variable "name" {}
# Policy
variable "policy" {}
# AWS Service
variable "identifier" {}



# IAM Role
resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
# IAM Assume Policy 
data "aws_iam_policy_document" "assume_role" {
  statement {
    # STS: get_tmp_credential → assume_policy
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}



# IAM Policy
resource "aws_iam_policy" "default" {
  name   = var.name
  policy = var.policy
}


# IAM Role + IAM Policy
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}



# output
output "iam_role_arn" {
  value = aws_iam_role.default.arn
}
output "iam_role_name" {
  value = aws_iam_role.default.name
}



# preference: https://dev.classmethod.jp/articles/iam-role-and-assumerole/