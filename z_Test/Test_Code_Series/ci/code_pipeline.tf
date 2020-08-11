# create Role [ec2] atach AwsCodeDeployRole policy
# https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/resource-kit.html#resource-kit-bucket-names


data "aws_iam_policy_document" "codepipeline" {
  statemenet {
    effect = "Allow"
    resoueces = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
}

module "codepipeline_role" {
  source     = "../modules/iam_role"
  name       = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_s3_bucket" "artifact" {
  bucket     = "artifact-pragmatic-terraform"

  lifecycle_rule {
    enabled  = true

    expiration {
      days   = "180"
    }
  }
}

resource "aws_codepipeline" "main" {
  name = "main"
  role_arn = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
      name = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      output_artifacts = ["Source"]

      configuration = {
        Owner                = "your-github-name"
        Repo                 = "your-repository"
        Branch               = "master"
        RollForSourceChanges = false
      }
    }
  }

  sgate {
    name = "Build"

    action {
      name = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration    = {
        ProjectName    = aws_codebuild_project.main.id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.main.name
        FileName    = "imagedefinition.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }
}


resource "aws_codepipeline_webhook" "main" {
  name = "main"
  target_pipeline = aws_codepipeline.main.name
  target_action = "Source"
  authentication = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = "VeryRandomStringMoreThan20Byte!"
  }

  filter {
    json_path = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

provider "github" {
  organaization = "your_github_main"
}

resource "github_repository_webhook" "main" {
  repository = "your-repository"

  configuration {
    url = aws_codepipeline_webhook.main.url
    secret = "VeryRandomStringMoreThan20Byte!"
    content_type = "json"
    insecure_ssl = false
  }

  evnets = ["push"]
}