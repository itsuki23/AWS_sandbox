# ------------------------------
#  Init
# ------------------------------
# only hard code
terraform {
  # required_version = "0.12.5"
  backend "s3" {
    region = "ap-northeast-1"
    bucket = "myk-tfstate"
    key    = "terraform.tfstate"
    # encrypt = true
  }
}

# ------------------------------
# Provider
# ------------------------------
provider "aws" {
  # vresion                 = "2.20.0"
  region                  = "ap-northeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "itsuki"
}
