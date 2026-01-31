provider "aws" {
  region = var.region
}

locals {
  name_prefix = "awesomeeksapp"
}

module "vpc" {
  source = "../modules/vpc-eks"

  vpc_cidr    = "10.0.0.0/16"
  name_prefix = local.name_prefix
  azs         = ["${var.region}a", "${var.region}b"]
}

module "eks" {
  source = "../modules/eks"

  cluster_name   = "${local.name_prefix}-cluster"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnets
  instance_types = ["t3a.medium"]
  desired_size   = 2
  min_size       = 1
  max_size       = 3

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

module "rds" {
  source = "../modules/rds"

  identifier              = "${local.name_prefix}-db"
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnets
  allowed_security_groups = [module.eks.cluster_security_group_id] # Allowing EKS cluster to access RDS

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# ACM Request and Validation
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => dvo
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = data.aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

module "alb" {
  source = "../modules/alb"

  name_prefix     = local.name_prefix
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}


resource "aws_security_group_rule" "nodes_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = module.alb.alb_security_group_id
}
