terraform {
  # required_version = "0.12.5"
  backend "s3" {
    bucket = "myk-tfstate"
    key    = "ecr/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  # vresion                 = "2.20.0"
  region                  = "ap-northeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "itsuki_miyake"
}