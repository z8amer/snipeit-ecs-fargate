variable "root_domain" {
  type        = string
  description = "main domain: zain-amer.co.uk"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "sub_domain" {
  type    = string
  default = "tm."
}

variable "dns_ttl" {
  type    = number
  default = 60
}

variable "alb_dns_name" {
  type        = string
  description = "Application Load Balancer DNS name"
}

variable "alb_zone_id" {
  type        = string
  description = "Application Load Balancer zone id"
}
