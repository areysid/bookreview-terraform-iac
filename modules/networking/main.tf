# AZs
data "aws_availability_zones" "azs" {
  state = "available"
}

# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# -------------------------------
# SUBNETS
# -------------------------------
locals {
  subnet_map = merge([
    for tier, config in var.subnets : {
      for idx, cidr in config.cidrs :
      "${tier}-${idx}" => {
        tier  = tier
        cidr  = cidr
        az    = data.aws_availability_zones.azs.names[idx]
        public = config.public
      }
    }
  ]...)
}

resource "aws_subnet" "this" {
  for_each = local.subnet_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${var.project}-${each.value.tier}-subnet-${each.key}"
  }
}

# -------------------------------
# IGW
# -------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# -------------------------------
# PUBLIC ROUTE TABLE
# -------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

# -------------------------------
# NAT
# -------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values({
    for k, v in aws_subnet.this :
    k => v if v.map_public_ip_on_launch
  })[0].id

  tags = {
    Name = "${var.project}-nat"
  }
}

# -------------------------------
# PRIVATE ROUTE TABLE
# -------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

# -------------------------------
# ROUTE TABLE ASSOCIATIONS
# -------------------------------
resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id = each.value.id
  route_table_id = each.value.map_public_ip_on_launch ? aws_route_table.public.id : aws_route_table.private.id
}