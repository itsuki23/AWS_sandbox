# https://qiita.com/gamisan9999/items/7ae592531e2aaf4b56d5


# aws_config.tf


resource "aws_config_configuration_recorder" "aws-config" {
  name     = "aws-config"
  role_arn = "${aws_iam_role.aws-config.arn}"
}

resource "aws_iam_role" "aws-config" {
  name = "aws-config"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "aws-config" {
  name = "aws-config"
  role = "${aws_iam_role.aws-config.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "config:Put*",
        "Effect": "Allow",
        "Resource": "*"
    },
    {
        "Action": [ "s3:Put*" ],
        "Effect": "Allow",
        "Resource": [
            "${aws_s3_bucket.aws-config.arn}",
            "${aws_s3_bucket.aws-config.arn}/*"
      ]
    }
  ]
}
POLICY
}


resource "aws_s3_bucket" "aws-config" {
  bucket = "${var.project}-aws-config"
}

resource "aws_config_delivery_channel" "aws-config" {
  name           = "${var.project}-aws-config"
  s3_bucket_name = "${aws_s3_bucket.aws-config.bucket}"
  sns_topic_arn = "${aws_sns_topic.lambda_to_slack.arn}"
  snapshot_delivery_properties {
    delivery_frequency = "Three_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "aws-config" {
  name       = "${aws_config_configuration_recorder.aws-config.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.aws-config"]
}
# add your custom rule is aws_config_custom.tf
# see config rule list
# https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/managed-rules-by-aws-config.html
resource "aws_config_config_rule" "ssh" {
    name = "restricted-ssh"
    source {
        owner = "AWS"
        source_identifier = "INCOMING_SSH_DISABLED"
    }
    scope {
        compliance_resource_types = ["AWS::EC2::SecurityGroup"]
    }
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}
resource "aws_config_config_rule" "r1" {
  name = "autoscaling-group-elb-healthcheck-required"
  source {
    owner             = "AWS"
    source_identifier = "AUTOSCALING_GROUP_ELB_HEALTHCHECK_REQUIRED"
  }
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}
resource "aws_config_config_rule" "r2" {
  name = "db-instance-backup-enabled"
  source {
    owner             = "AWS"
    source_identifier = "DB_INSTANCE_BACKUP_ENABLED"
  }
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}
resource "aws_config_config_rule" "r3" {
  name = "s3-bucket-logging-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LOGGING_ENABLED"
  }
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}
resource "aws_config_config_rule" "r4" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"

  }
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}
resource "aws_config_config_rule" "r5" {
  name = "s3-bucket-public-write-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"

  }
  depends_on = ["aws_config_configuration_recorder.aws-config"]






  # aws_config_custom.tf

  resource "aws_config_config_rule" "mng-cms" {
    name = "restricted-mng-cms"
    source {
        owner = "AWS"
        source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
    }
    scope {
        compliance_resource_types = ["AWS::EC2::SecurityGroup"]
        compliance_resource_id = "${aws_security_group.mng-cms-elb.id}"
    }
    input_parameters = "{\"blockedPort1\":\"443\",\"blockedPort2\":\"80\"}"
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}
resource "aws_config_config_rule" "develop-cms" {
    name = "restricted-develop-cms"
    source {
        owner = "AWS"
        source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
    }
    scope {
        compliance_resource_types = ["AWS::EC2::SecurityGroup"]
        compliance_resource_id = "${aws_security_group.develop-cms-elb.id}"
    }
    input_parameters = "{\"blockedPort1\":\"443\",\"blockedPort2\":\"80\"}"
  depends_on = ["aws_config_configuration_recorder.aws-config"]
}





# aws_sns.tf


# 神=> https://github.com/builtinnya/aws-sns-slack-terraform
module "sns_to_slack" {
  source = "github.com/builtinnya/aws-sns-slack-terraform/module"

  slack_webhook_url = "${var.oreno_slack_webhook_url}"
  slack_channel_map = "{ \"lambda_to_slack\": \"#notify-hoghoge\" }"
}

resource "aws_sns_topic" "lambda_to_slack" {
  name = "lambda_to_slack"
}

resource "aws_lambda_permission" "allow_lambda_sns_to_slack" {
  statement_id = "AllowSNSToSlackExecutionFromSNS"
  action = "lambda:invokeFunction"
  function_name = "${module.sns_to_slack.lambda_function_arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.lambda_to_slack.arn}"
}

resource "aws_sns_topic_subscription" "lambda_sns_to_slack" {
  topic_arn = "${aws_sns_topic.lambda_to_slack.arn}"
  protocol = "lambda"
  endpoint = "${module.sns_to_slack.lambda_function_arn}"
}
