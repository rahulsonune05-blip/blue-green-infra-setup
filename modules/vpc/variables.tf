variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks."
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones to use for subnets."
  type        = list(string)
}

variable "project_name" {
  description = "A common tag for all resources."
  type        = string
}