resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(
    var.common_tags,
    var.vpc_tags,{
        Name = local.vpc_name
    }
  )
}

#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.gateway_tags,
    {
    Name = local.igw_name
    }
  )
}

#public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${local.availability_zone[count.index]}"
  }
}

#private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.availability_zone[count.index]
  #map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet-${local.availability_zone[count.index]}"
  }
}

#database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = local.availability_zone[count.index]
  #map_public_ip_on_launch = true
  tags = {
    Name = "database-subnet-${local.availability_zone[count.index]}"
  }
}

#elastic ip
resource "aws_eip" "lb" {
  domain   = "vpc"
  tags = {
    Name = "elastic-ip-nat"
  }
}

#natgateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
 tags = {
   Name = "roboshop-dev-public-route-table"
 }
}

#private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
 tags = {
   Name = "roboshop-dev-private-route-table"
 }
}

#database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
 tags = {
   Name = "roboshop-dev-database-route-table"
 }
}

#public route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

#private route
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example.id
}
#database route
resource "aws_route" "private" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example.id
}


#public route table assotiation
resource "aws_route_table_association" "example" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#private route table assotiation
resource "aws_route_table_association" "example" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#database route table assotiation
resource "aws_route_table_association" "example" {
  count = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
