variable "vpc_cidr" {
  type        = string
  default     = "100.0.0.0/16"
  description = "VPC CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["100.0.1.0/24", "100.0.2.0/24"]
  description = "List of Public Subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["100.0.3.0/24", "100.0.4.0/24"]
  description = "List of Private Subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
  description = "The physical data centers to split resources across"
}

variable "project_name" {
  type        = string
  default     = "snipe-ict-ECS"
  description = "Project name"
}

variable "root_domain" {
  type        = string
  default     = "zain-amer.co.uk"
  description = "Primary domain of Hosted Zone"
}

variable "existing_ecr_url" {
  type        = string
  default     = "954405334747.dkr.ecr.eu-north-1.amazonaws.com/snipe-it-ecs"
  description = "The URL path of pre-existing ECR"
}
