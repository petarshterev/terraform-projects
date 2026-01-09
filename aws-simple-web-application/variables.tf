variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "simplewebapp.com"
}

variable "ami_name_filter" {
  description = "AMI name filter for Amazon Linux 2"
  type        = string
  default     = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "aws_instances_number" {
  description = "Number of EC2 instances to provision"
  type        = number
  default     = 2
}

variable "aws_state_bucket_name" {
  description = "Name for the S3 bucket where the terraform.tfstate file is stored"
  type        = string
  default     = "simple-web-application-terraform-state"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.medium"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_engine" {
  description = "RDS engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "13"
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_ec2" {
  description = "Private subnet CIDRs for EC2"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnets_rds" {
  description = "Private subnet CIDRs for RDS"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}