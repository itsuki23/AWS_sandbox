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
# Public Subnet
# ------------------------------
# ALB 1a
resource "aws_subnet" "alb_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_alb_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name"    = "${local.prefix}-public-alb-1a"
    "Project" =    local.prefix
  }
}

# ALB 1c
resource "aws_subnet" "alb_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_alb_1c_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name"    = "${local.prefix}-public-alb-1c"
    "Project" =    local.prefix
  }
}

# Maintenance 1a
resource "aws_subnet" "maintenance_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_maintenance_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name"    = "${local.prefix}-public-alb-1a"
    "Project" =    local.prefix
  }
}

# Maintenance 1c
resource "aws_subnet" "maintenance_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_maintenance_1c_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name"    = "${local.prefix}-public-alb-1c"
    "Project" =    local.prefix
  }
}

# ------------------------------
# Private Subnet
# ------------------------------
# Server 1a
resource "aws_subnet" "server_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_server_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    "Name"    = "${local.prefix}-private-server-1a"
    "Project" =    local.prefix
  }
}

# Server 1c
resource "aws_subnet" "server_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_server_1c_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    "Name"    = "${local.prefix}-private-server-1c"
    "Project" =    local.prefix
  }
}

# DB 1a
resource "aws_subnet" "db_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_db_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    "Name"    = "${local.prefix}-private-db-1a"
    "Project" =    local.prefix
  }
}

# DB 1c
resource "aws_subnet" "db_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_db_1c_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    "Name"    = "${local.prefix}-private-db-1c"
    "Project" =    local.prefix
  }
}

# ------------------------------
# Internet Gateway
# ------------------------------
# IGW
resource "aws_internet_gateway" "main" {
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name"    = "${local.prefix}-igw"
    "Project" =    local.prefix
  }
}

# ------------------------------
# Nat Gateway
# ------------------------------
# NGW
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.maintenance_1c.id
  depends_on    = [aws_internet_gateway.main]
}

# EIP
resource "aws_eip" "nat_gateway" {
  vpc         = true
  depends_on  = [aws_internet_gateway.main]
  tags = {
    "Name"    = "${local.prefix}-nat-eip"
    "Project" =    local.prefix
  }
}

# ※ Normaly create nat_gateway each AZ
#   (NAT cannot be used if there is a failure in either AZ)
# ⇒ Usually
#    NGW*n
#    EIP*n
#    RouteTable.private*n
#    Route.private*n
#    Assosiation.private*n

# ------------------------------
# Route Table
# ------------------------------
# MainRT
resource "aws_route_table" "main" {
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name"    = "${local.prefix}-main-rt"
    "Project" = local.prefix
  }
}

# PublicRT
resource "aws_route_table" "public" {
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name"    = "${local.prefix}-public-rt"
    "Project" = local.prefix
  }
}

# PrivateRT
resource "aws_route_table" "private" {
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name"    = "${local.prefix}-private-rt"
    "Project" = local.prefix
  }
}

# ------------------------------
# Route
# ------------------------------
# MainRT [-]
# -

# PublicRT [IGW]
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

# PrivateRT [NGW]
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}


# ------------------------------
# Assosiate
# ------------------------------
# default
# VPC + MainRT [-]
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

# Public
# ALB 1a + PublicRT [igw]
resource "aws_route_table_association" "alb_1a" {
  subnet_id      = aws_subnet.alb_1a.id
  route_table_id = aws_route_table.public.id
}
# ALB 1c + PublicRT [igw]
resource "aws_route_table_association" "alb_1c" {
  subnet_id      = aws_subnet.alb_1c.id
  route_table_id = aws_route_table.public.id
}
# Maintenance 1a + PublicRT [igw]
resource "aws_route_table_association" "maintenance_1a" {
  subnet_id      = aws_subnet.maintenance_1a.id
  route_table_id = aws_route_table.public.id
}
# Maintenance 1c + PublicRT [igw]
resource "aws_route_table_association" "maintenance_1c" {
  subnet_id      = aws_subnet.maintenance_1c.id
  route_table_id = aws_route_table.public.id
}

# Private
# Server 1a + PrivateRT [-]
resource "aws_route_table_association" "server_1a" {
  subnet_id      = aws_subnet.server_1a.id
  route_table_id = aws_route_table.private.id
}
# Server 1c + PrivateRT [-]
resource "aws_route_table_association" "server_1c" {
  subnet_id      = aws_subnet.server_1c.id
  route_table_id = aws_route_table.private.id
}
# DB 1a + PrivateRT [-]
resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.private.id
}
# DB 1c + PrivateRT [-]
resource "aws_route_table_association" "db_1c" {
  subnet_id      = aws_subnet.db_1c.id
  route_table_id = aws_route_table.private.id
}





