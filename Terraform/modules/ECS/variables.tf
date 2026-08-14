variable "project_name" {
  type        = string
  description = "Project name"
}

variable "existing_ecr_url" {
  type        = string
  description = "The  URL path of pre-existing ECR"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnets"
}

variable "target_group_arn" {
  type        = string
  description = "ALB TG ARN"
}

variable "alb_security_group_id" {
  type        = string
  description = "ID of ALB security Group"
}

variable "ecs_setting_name" {
  type        = string
  default     = "containerInsights"
  description = "Name of cluster setting"
}

variable "ecs_setting_value" {
  type        = string
  default     = "enabled"
  description = "value is either 'enabled' or 'disabled'"
}

variable "container_name" {
  type    = string
  default = "app_container"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "host_port" {
  type    = number
  default = "80"
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "log_prefix" {
  type    = string
  default = "ecs"
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "service_desired_count" {
  type    = number
  default = 1
}

variable "log_retention_days" {
  type    = number
  default = 60
}

variable "vpc_id" {
  type        = string
  description = "main VPC ID"
}
