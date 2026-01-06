resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.environment}-vpc"
    Env  = var.environment
  }
  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Creating public subnets (one per AZ)
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-${count.index}"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}



# Creating public subnets (one per AZ)
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.myvpc.id
  availability_zone = var.availability_zones[count.index]
  cidr_block = var.private_subnet_cidrs[count.index]
  tags = {
    Name = "${var.environment}-private-${count.index}"
  }
}

resource "aws_eip" "nat_eip" {
  count = length(aws_subnet.public)
  domain = "vpc" 
  tags = {
    Name = "${var.environment}-nat-eip-${count.index}"
  }

}

resource "aws_nat_gateway" "nat" {
  count = length(aws_subnet.public)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.environment}-NAT-${count.index}"
  }
  depends_on = [ aws_internet_gateway.igw ]
  }

resource "aws_route_table" "private_rt" {
  count = length(aws_subnet.private)
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.environment}-private-rt-${count.index}"
  }
  }

  resource "aws_route_table_association" "private-rt-assoc" {
    count = length(aws_subnet.private)
    subnet_id = aws_subnet.private[count.index].id 
    route_table_id = aws_route_table.private_rt[count.index].id
  }