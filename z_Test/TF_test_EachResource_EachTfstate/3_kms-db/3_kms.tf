# Customer Master Key
resource "aws_kms_key" "main" {
  description             = "main Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

# Aliace
resource "aws_kms_alias" "main" {
  name = "alias/main"  # Aliace must named「alias/...」
  target_key_id = aws_kms_key.main.key_id
}