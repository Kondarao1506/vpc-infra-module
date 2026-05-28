#compulsory pass from module user
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_tags" {
  type = map
  default = {
    component = "vpc"
    project = "roboshop"
    environment = "dev"
  }
}

variable "vpc_cidr_block" {
  type = string
}

variable "common_tags" {
  default = {}
}

variable "gateway_tags" {
  default = {

  }
}

#public subnet
variable "public_subnet_cidr" {
  type = list
}

variable "private_subnet_cidr" {
  type = list
}

variable "database_subnet_cidr" {
  type = list
}