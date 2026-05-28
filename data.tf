data "aws_availability_zones" "available" {
  state = "available"
}

output "availability_zone" {
  value = data.aws_availability_zones.available
}