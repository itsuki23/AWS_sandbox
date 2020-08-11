terraform {
  # required_version = "0.12.5"
}

provider "aws" {
  # vresion                 = "2.20.0"
  region                  = "ap-northeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "itsuki_miyake"
}
