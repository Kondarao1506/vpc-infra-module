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