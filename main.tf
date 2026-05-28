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

