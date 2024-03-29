locals {
  vpc_cidr = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "woodnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_count = 2
  azs          = data.aws_availability_zones.available.names
  az_count     = length(data.aws_availability_zones.available.names)
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# resource "aws_nat_gateway" "this" {
#   count = local.subnet_count % local.az_count

#   allocation_id = "${aws_eip.nat.id}"
#   subnet_id     = "${aws_subnet.public.0.id}"

#   tags = {
#     Name = "${var.service_name}-nat-gw"
#   }
# }

resource "aws_subnet" "private" {
  count = local.subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index * 2 + 1}.0/24"
  availability_zone = local.azs[count.index % local.az_count]

  tags = {
    Name = "Private ${count.index}"
  }
}

resource "aws_subnet" "public" {
  count = local.subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index * 2}.0/24"
  availability_zone = local.azs[count.index % local.az_count]

  tags = {
    Name = "Public ${count.index}"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
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