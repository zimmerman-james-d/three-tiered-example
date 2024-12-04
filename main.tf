terraform {
  backend "s3" {
  }
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "api_gateway" {
  source = "./modules/api_gateway"

  domain                 = var.domain
  vpc                    = module.vpc.vpc
  subnets                = module.vpc.subnets
  cert_arn               = var.cert_arn
  load_balancer_listener = module.load_balancer.lb_listener
  environment            = var.environment
}

module "load_balancer" {
  source      = "./modules/load_balancer"
  subnets     = module.vpc.subnets
  vpc         = module.vpc.vpc
  environment = var.environment
}

module "container_service" {
  count        = var.ecs.enabled ? 1 : 0
  source       = "./modules/container_service"
  subnets      = module.vpc.subnets
  vpc          = module.vpc.vpc
  target_group = module.load_balancer.target_group
  alb          = module.load_balancer.alb
  environment  = var.environment
  aws_region   = var.aws_region
}

module "ec2" {
  count         = var.ec2.enabled ? 1 : 0
  source        = "./modules/ec2"
  vpc           = module.vpc.vpc
  subnets       = module.vpc.subnets
  operator_cidr = var.operator_cidr
  key_name      = var.key_name
}

module "rds_instance" {
  count       = var.db.rds_instance ? 1 : 0
  source      = "./modules/rds_instance"
  subnets     = module.vpc.subnets
  vpc         = module.vpc.vpc
  environment = var.environment
}

module "rds_cluster" {
  count       = var.db.rds_cluster ? 1 : 0
  source      = "./modules/rds_cluster"
  subnets     = module.vpc.subnets
  vpc         = module.vpc.vpc
  environment = var.environment
}

module "s3" {
  source      = "./modules/s3"
  environment = var.environment
  s3_cert_arn = var.s3_cert_arn
}
