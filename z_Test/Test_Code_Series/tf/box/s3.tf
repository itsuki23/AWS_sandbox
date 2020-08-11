# # ------------------------------
# # Public
# # ------------------------------
# resource "aws_s3_bucket" "public" {
#   bucket = ""
#   acl    = "public-read"

#   cors_rule {
#     allowed_origins = ["https://example.com"]
#     allowed_methods = ["GET"]
#     allowed_headers = ["*"]
#     max_age_seconds = 3000
#   }
#   # force_destroy = true
# }


# # ------------------------------
# # Private
# # ------------------------------
# resource "aws_s3_bucket" "private" {
#   bucket = ""
#   versioning { enabled = true}
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
#   # force_destroy = true
# }

# resource "aws_s3_bucket_public_access_block" "private" {
#   bucket = aws_s3_bucket.private.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
