module "vpc" {
  source               = "./modules/VPC"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "public_load_balancer" {
  source            = "./modules/ALB"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.security_acm.certificate_arn
}

module "security_acm" {
  source       = "./modules/acm_route53"
  project_name = var.project_name
  domain       = "${var.sub_domain}.${var.root_domain}"
  alb_dns_name = module.public_load_balancer.alb_dns_name
  alb_zone_id  = module.public_load_balancer.alb_zone_id
}

module "ecs_compute" {
  source                = "./modules/ECS"
  project_name          = var.project_name
  private_subnet_cidrs  = module.vpc.private_subnet_ids
  target_group_arn      = module.public_load_balancer.target_group_arn
  existing_ecr_url      = var.existing_ecr_url
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.public_load_balancer.alb_security_group_id
  depends_on            = [module.public_load_balancer]
}

