# ------------------------------
# ALB Log
# ------------------------------
resource "aws_s3_bucket" "alb_log" {
  bucket = ""
  lifecycle_rule {
    enabled = true
    expiration { days = "30"}
  }
  # force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type = "AWS"
      # case by ap-northeast-1
      identifiers = ["582318560864"]
      # preference: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html
    }
  }
}

# ------------------------------
# SSM Operation Log
# ------------------------------
# s3 bucket
resource "aws_s3_bucket" "operation" {
  bucket   = "${module.var.prefix}-operation"

  lifecycle_rule {
    enable = true

    expiration {
      days = "180"
    }
  }
}

# cloud watch
resource "aws_cloudwatch_log_group" "operation" {
  name              = "/operation"
  retention_in_days = 180
}

# ssm document
resource "aws_ssm_document" "ssession_manager_run_shell" {
  name = "SSM-SessionManagerRunShell"
  docuemnt_type = "Session"
  docuemnt_format = "JSON"

  content = <<EOF
  {
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
      "s3BucketName": "${aws_s3_bucket.operation.id}",
      "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.operation.name}"
    }
  }
EOF
}

# ------------------------------
# ECS
# ------------------------------
# cloud watch
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/main" 
  retention_in_days = 180
}

# get iam policy managed by aws    ★1
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# get policy document(setting statement)    ★2
data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy    # ★1
  
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "kms:Decrypt"]
    resources = ["*"]
  }
}

# create iam role
module "ecs_task_execution_role" {
  source     = "../modules/iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json    # ★2
}


