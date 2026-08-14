variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr" {
  type        = string
  description = "main CIDR for main VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "availbility zones"
}


