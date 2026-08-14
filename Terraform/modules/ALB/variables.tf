variable "project_name" {
  type        = string
  description = "Project name"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The list of public subnet IDs where the ALB will be deployed"
}

variable "vpc_id" {
  type        = string
  description = "main VPC ID"

}

variable "certificate_arn" {
  type        = string
  description = "ARN of ACM SSL certificate"
}

variable "https_port" {
  type    = number
  default = 443
}

variable "container_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-2016-08"
}
