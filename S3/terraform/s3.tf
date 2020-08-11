# ------------------------------
# Private
# ------------------------------
resource "aws_s3_bucket" "private" {
  # unique name
  bucket = ""

  versioning {
    enable = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------
# Public
# ------------------------------
resource "aws_s3_bucket" "public" {
  bucket = ""
  acl    = "public-read"

  cors_rule {
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

# ------------------------------
# Log
# ------------------------------
# ex ALB
resource "aws_s3_bucket" "alb_log" {
  bucket = ""

  lifecycle_rule {
    enabled = true

    expiration {
      days = "30"
    }
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
      # preference: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html
      # case by ap-northeast-1
      identifiers = ["582318560864"]
    }
  }
}
 