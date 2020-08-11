
# ------------------------------
# VPC
# ------------------------------
# MainVPC
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name"    = "${local.prefix}-vpc"
    "Project" =    local.prefix
  }
}

# ------------------------------
# Subnet
# ------------------------------
# PublicSubnet-1a
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags                    = {
    "Name"    = "${local.prefix}-public-subnet-1a"
    "Project" =    local.prefix
  }
}

# PublicSubnet-1c
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_1c_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags                    = {
    "Name"    = "${local.prefix}-public-subnet-1c"
    "Project" =    local.prefix
  }
}

# PrivateSubnet-1a
resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_sublet_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags        = {
    "Name"    = "${local.prefix}-private-subnet-1a"
    "Project" =    local.prefix
  }
}

# PrivateSubnet-1a
resource "aws_subnet" "main_private_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_sublet_1c_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags        = {
    "Name"    = "${local.prefix}-private-subnet-1c"
    "Project" =    local.prefix
  }
}