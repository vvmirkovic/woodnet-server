locals {
    vpc_cidr = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block       = local.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "woodnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_count = 2
  azs = data.aws_availability_zones.available.names
  az_count = length(data.aws_availability_zones.available.names)
}


resource "aws_subnet" "public" {
  count = local.subnet_count

  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index * 2}.0/24"
  availability_zone = local.azs[count.index % local.az_count]

  tags = {
    Name = "Public 1"
  }
}

resource "aws_subnet" "private" {
  count = local.subnet_count

  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index * 2 + 1}.0/24"
  availability_zone = local.azs[count.index % local.az_count]

  tags = {
    Name = "Private ${count.index}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = local.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = local.vpc_cidr
    gateway_id = "local"
  }

  route {
    ipv4_cidr_block        = "0.0.0.0/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private" {
  count = local.subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count = local.subnet_count
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}