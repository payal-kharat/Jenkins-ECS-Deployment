# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ============================================================
# PUBLIC SUBNETS - ALB + NAT GATEWAY
# ============================================================

resource "aws_subnet" "public" {
  for_each = {
    for index, az in var.availability_zones : az => index
  }

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = var.public_subnet_cidrs[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${each.key}"
    Tier = "public"
  }
}

# ============================================================
# PRIVATE SUBNETS - ECS TASKS / DATABASE
# ============================================================

resource "aws_subnet" "private" {
  for_each = {
    for index, az in var.availability_zones : az => index
  }

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = var.private_subnet_cidrs[each.value]

  tags = {
    Name = "${var.project_name}-private-${each.key}"
    Tier = "private"
  }
}

# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# NAT GATEWAY
# One NAT Gateway is used to keep the initial infrastructure
# cost lower. Both private subnets route outbound traffic to it.
# ============================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat"
  }
}

# ============================================================
# PRIVATE ROUTE TABLE
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
