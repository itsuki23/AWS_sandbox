# ------------------------------
# Lifecycpe Policy
# ------------------------------
locals {
  ecr_lifecycle_policy {
    # use
    keep_30_release_tagged = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 release tagged images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["release"],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
    # unuse
    expire_older_14_days = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
  }
}

# ------------------------------
# ECR
# ------------------------------
# create Repo
resource "aws_ecr_repository" "main" {
  name = "${local.prefix}-repo"
}

# Lifecycle policy
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = local.ecr_lifecycle_policy.keep_30_release_tagged
}



