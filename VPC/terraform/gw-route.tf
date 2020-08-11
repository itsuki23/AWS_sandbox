# ------------------------------
# InternetGateway
# ------------------------------
# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = {
    "Name"    = "${local.prefix}-igw"
    "Project" =    local.prefix
  }
}

# ------------------------------
# NatGateway
# ------------------------------
# NGW
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = data.aws_ssm_parameter.public_subnet_1a_id.value
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
# ⇒ Usually NGW*n EIP*n RouteTable*n Route*n Assosiation*n

# ------------------------------
# RouteTable
# ------------------------------
# MainRT
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags   = {
    "Name"    = "${local.prefix}-main-rt"
    "Project" =    local.prefix
  }
}

# PublicRT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = {
    "Name"    = "${local.prefix}-public-rt"
    "Project" =    local.prefix
  }
}

# PrivateRT
resource "aws_route_table" "private" {
  vpc_id      = aws_vpc.main.id
  tags        = {
    "Name"    = "${local.prefix}-private-rt"
    "Project" =    local.prefix
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
# VPC + MainRT (★default [-])
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

# PublicSubnet-1a + PublicRT [igw]
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}
# PublicSubnet-1c + PublicRT [igw]
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# PrivateSubnet-1a + PrivateRT [-]
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}
# PrivateSubnet-1c + PrivateRT [-]
resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}



