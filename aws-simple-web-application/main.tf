terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = var.aws_state_bucket_name
    key    = "workspace/terraform.tfstate"
    region = var.region
    encrypt        = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

### Retrieving some modules
## AWS EC2 instance module

module "aws_instance" {
  source = "../modules/aws_instance"

  ami               = data.aws_ami.amazon_linux.id
  instance_type     = var.instance_type
  instance_count    = var.aws_instances_number
  security_groups   = [aws_security_group.ec2.id]
  subnet_ids        = aws_subnet.private_ec2[*].id
  user_data         = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from Instance \${count.index + 1}</h1>" > /var/www/html/index.html
EOF
  tags = {
    Project = "SimpleWebApplication"
    Name    = "app-instance"
  }
}

### Create private encrypted S3 bucket with enabled versioning and DynamoDB table for the terraform state files.
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.aws_state_bucket_name
  object_lock_enabled = true
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Project = "SimpleWebApplication"
    Name    = "main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Project = "SimpleWebApplication"
    Name    = "main-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Project = "SimpleWebApplication"
    Name    = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_ec2" {
  count             = length(var.private_subnets_ec2)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_ec2[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Project = "SimpleWebApplication"
    Name    = "private-ec2-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_rds" {
  count             = length(var.private_subnets_rds)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_rds[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Project = "SimpleWebApplication"
    Name    = "private-rds-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Project = "SimpleWebApplication"
    Name    = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Project = "SimpleWebApplication"
    Name    = "private-rt"
  }
}

resource "aws_route_table_association" "private_ec2" {
  count          = length(aws_subnet.private_ec2)
  subnet_id      = aws_subnet.private_ec2[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_rds" {
  count          = length(aws_subnet.private_rds)
  subnet_id      = aws_subnet.private_rds[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project = "SimpleWebApplication"
    Name    = "alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project = "SimpleWebApplication"
    Name    = "ec2-sg"
  }
}

resource "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project = "SimpleWebApplication"
    Name    = "rds-sg"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dv in aws_acm_certificate.cert.domain_validation_options : dv.domain_name => {
      name   = dv.resource_record_name
      record = dv.resource_record_value
      type   = dv.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
  depends_on      = [ aws_acm_certificate.cert ]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  depends_on              = [ aws_route53_record.cert_validation ]
}

resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  tags = {
    Project = "SimpleWebApplication"
    Name    = "main-alb"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"      
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count            = length(module.aws_instance.instance_ids)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = module.aws_instance.instance_ids[count.index]
  port             = 80
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.private_rds[*].id
  tags = {
    Project = "SimpleWebApplication"
    Name = "main-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "main-postgres"
  allocated_storage      = 20
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  tags = {
    Project = "SimpleWebApplication"
    Name    = "main-postgres"
  }
}

