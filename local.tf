locals {
  vpc_name = "${var.project}-${var.environment}-vpc"
  igw_name = "${var.project}-${var.environment}-gw"
  availability_zone = slice(data.aws_availability_zones.available.names,0,2)
}