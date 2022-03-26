# --------------------------------------------------------------
# vpc Creation
# --------------------------------------------------------------
resource "aws_vpc"  "vpc" {
    
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
    
  tags = {
    Name    = var.project
    project = var.project
  }
    
}

# --------------------------------------------------------------
# igw Creation
# --------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = var.project
    project = var.project
  }
}

# --------------------------------------------------------------
# public subnet1
# --------------------------------------------------------------

resource "aws_subnet" "public1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,3, 0)
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public1"
    project = var.project
  }
}


# --------------------------------------------------------------
# public subnet2
# --------------------------------------------------------------

resource "aws_subnet" "public2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,3, 1)
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public2"
    project = var.project
  }
}

# --------------------------------------------------------------
# public subnet3
# --------------------------------------------------------------

resource "aws_subnet" "public3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,3, 2)
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public3"
    project = var.project
  }
}



# --------------------------------------------------------------
# private subnet1
# --------------------------------------------------------------

resource "aws_subnet" "private1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,3, 3)
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private1"
    project = var.project
  }
}

# --------------------------------------------------------------
# private subnet2
# --------------------------------------------------------------

resource "aws_subnet" "private2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,3, 4)
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private2"
    project = var.project
  }
}

# --------------------------------------------------------------
# private subnet3
# --------------------------------------------------------------

resource "aws_subnet" "private3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,3, 5)
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private3"
    project = var.project
  }
}


# --------------------------------------------------------------
# Public Route table Creation
# --------------------------------------------------------------

resource "aws_route_table" "public" {
    
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    
  tags = {
    Name    = "${var.project}-public"
    project = var.project
  }
}


# --------------------------------------------------------------
# association between public1 to public rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------------------
# association between public2 to public rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


# --------------------------------------------------------------
# association between public3 to public rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}


# --------------------------------------------------------------
# Elastic Ip Creation
# --------------------------------------------------------------

resource "aws_eip" "nat" {

  vpc      = true
  tags = {
    Name    = "${var.project}-nat-gw"
    project = var.project
  }
}

# --------------------------------------------------------------
# NatGateWay Creation
# --------------------------------------------------------------

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name    = "${var.project}-nat"
    project = var.project
  }

  depends_on = [ aws_internet_gateway.igw ]
}

# --------------------------------------------------------------
# Creating Private Routetable
# --------------------------------------------------------------

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-private"
    project = var.project
  }
}


# --------------------------------------------------------------
# association between private1 to private rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

# --------------------------------------------------------------
# association between private2 to private rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}


# --------------------------------------------------------------
# association between private3 to private rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
