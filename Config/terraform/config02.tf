# https://qiita.com/tonishy/items/5f1f03057c1b2e56f13a

# provider.tf
provider "aws" {
  version                 = "2.48.0"
  shared_credentials_file = "../../../credentials"
  profile                 = "terraform"
  region                  = "ap-northeast-1"
}

# anyservice/anyenv/s3/backend.tf

terraform {
  required_version = ">= 0.12.9"
  backend "s3" {
    shared_credentials_file = "../../../credentials"
    profile                 = "terraform"
    region                  = "ap-northeast-1"
    bucket                  = "terraform-tfstate-チョメチョメ"
    key                     = "anyservice/anyenv/s3/terraform.tfstate"
  }
}


# anyservice/anyenv/s3/awsconfig.tf

data "aws_caller_identity" "current" {
}
resource "aws_s3_bucket" "awsconfig" {
  bucket        = "awsconfig-${data.aws_caller_identity.current.account_id}"
  acl           = "private"
  force_destroy = "false"
  region        = "ap-northeast-1"
  versioning {
    enabled = true
  }
}
data "aws_iam_policy_document" "s3bucket_policy-awsconfig" {
  version = "2012-10-17"
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "${aws_s3_bucket.awsconfig.arn}"
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.awsconfig.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
resource "aws_s3_bucket_policy" "awsconfig" {
  bucket = "${aws_s3_bucket.awsconfig.bucket}"
  policy = "${data.aws_iam_policy_document.s3bucket_policy-awsconfig.json}"
}
output "awsconfig_arn" {
  value = aws_s3_bucket.awsconfig.arn
}
output "awsconfig_name" {
  value = aws_s3_bucket.awsconfig.id
}

# terraform_remote_state.tf

data "terraform_remote_state" "S3" {
  backend = "s3"
  config = {
    shared_credentials_file = "../../../credentials"
    profile                 = "terraform"
    region                  = "ap-northeast-1"
    bucket                  = "terraform-tfstate-チョメチョメ"
    key                     = "anyservice/anyenv/s3/terraform.tfstate"
  }
}

# anyservice/anyenv/iam/backend.tf

terraform {
  required_version = ">= 0.12.9"
  backend "s3" {
    shared_credentials_file = "../../../credentials"
    profile                 = "terraform"
    region                  = "ap-northeast-1"
    bucket                  = "terraform-tfstate-チョメチョメ"
    key                     = "anyservice/anyenv/iam/terraform.tfstate"
  }
}

# anyservice/anyenv/iam/awsconfig.tf

data "aws_caller_identity" "current" {
}
data "aws_iam_policy_document" "assume_role_policy-awsconfig" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}
resource "aws_iam_role" "role_awsconfig" {
  name               = "awsconfig"
  path               = "/service-role/"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy-awsconfig.json}"
}
resource "aws_iam_role_policy_attachment" "awsconfig_AWSConfigRole" {
  role       = aws_iam_role.role_awsconfig.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}
data "aws_iam_policy_document" "iam_policy-awsconfig" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*"
    ]
    resources = [
      "${data.terraform_remote_state.S3.outputs.awsconfig_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      data.terraform_remote_state.S3.outputs.awsconfig_arn
    ]
  }
}
resource "aws_iam_policy" "iam_policy-awsconfig" {
  name   = "awsconfig"
  policy = "${data.aws_iam_policy_document.iam_policy-awsconfig.json}"
}
resource "aws_iam_role_policy_attachment" "awsconfig" {
  role       = aws_iam_role.role_awsconfig.name
  policy_arn = "${aws_iam_policy.iam_policy-awsconfig.arn}"
}
output "role_awsconfig_arn" {
  value = aws_iam_role.role_awsconfig.arn
}

# terraform_remote_state.tf

data "terraform_remote_state" "IAM" {
  backend = "s3"
  config = {
    shared_credentials_file = "../../../credentials"
    profile                 = "terraform"
    region                  = "ap-northeast-1"
    bucket                  = "terraform-tfstate-チョメチョメ"
    key                     = "anyservice/anyenv/iam/terraform.tfstate"
  }
}

#   anyservice/anyenv/awsconfig/backend.tf

terraform {
  required_version = ">= 0.12.9"
  backend "s3" {
    shared_credentials_file = "../../../credentials"
    profile                 = "terraform"
    region                  = "ap-northeast-1"
    bucket                  = "terraform-tfstate-チョメチョメ"
    key                     = "anyservice/anyenv/awsconfig/terraform.tfstate"
  }
}

# anyservice/anyenv/awsconfig/main.tf

data "aws_caller_identity" "current" {
}
resource "aws_config_configuration_recorder" "awsconfig" {
  name     = "awsconfig-${data.aws_caller_identity.current.account_id}"
  role_arn = data.terraform_remote_state.IAM.outputs.role_awsconfig_arn
  recording_group {
    all_supported                 = "true"
    include_global_resource_types = "true"
  }
}
resource "aws_config_delivery_channel" "awsconfig" {
  name           = "awsconfig-${data.aws_caller_identity.current.account_id}"
  s3_bucket_name = data.terraform_remote_state.S3.outputs.awsconfig_name
  depends_on     = ["aws_config_configuration_recorder.awsconfig"]
  snapshot_delivery_properties {
    delivery_frequency = "One_Hour"
  }
}