terraform {
  # required_version = "0.12.5"
  backend "s3" {
    bucket = "myk-tfstate"
    key    = "route53-alb/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  # vresion                 = "2.20.0"
  region                  = "ap-northeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "itsuki_miyake"
}

# for getting my public IP
provider "http" {
  version = "~> 1.1"
}
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}