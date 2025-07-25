# Create the VPC

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "EKS"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# Create Public Subnets

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # Public subnets should auto-assign public IPs

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = "Public"
  }
}

# Create Private Subnets

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-private-subnet-${count.index + 1}"
    Project     = var.project_name
    Environment = "Private"
  }
}

# Create Elastic IP for NAT Gateway

resource "aws_eip" "nat" {
  count = length(var.public_subnets) # One EIP per public subnet for NAT Gateway
  domain = "vpc"

  tags = {
    Name    = "${var.project_name}-nat-eip-${count.index + 1}"
    Project = var.project_name
  }
}

# Create NAT Gateway

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # Place NAT Gateway in public subnet

  tags = {
    Name    = "${var.project_name}-nat-gateway-${count.index + 1}"
    Project = var.project_name
  }
  # Ensure NAT Gateway is created after Internet Gateway is attached
  depends_on = [aws_internet_gateway.this]
}

# Create Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

# Add route to Internet Gateway for Public Route Table

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate Public Subnets with Public Route Table

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Private Route Tables (one per private subnet for NAT Gateway)

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project_name}-private-rt-${count.index + 1}"
    Project = var.project_name
  }
}

# Add route to NAT Gateway for Private Route Tables

resource "aws_route" "private_nat_gateway" {
  count                  = length(aws_route_table.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id # Associate with corresponding NAT Gateway
}

# Associate Private Subnets with Private Route Tables

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
