# ex) role [service: action]

data "aws_iam_policy_document" "allow_describe_regions" {
  atatement {
    effect    = "Allow"
    actions   = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}

module "describe_region_for_ec2" {
  source     = "./iam_role"
  name       = "..."
  identifier = "ec2.amazon.com"
  policy     = data.aws.iam_policy_document.allow_describe_regions.json
}