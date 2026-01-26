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

variable "project" {
  description = "Project name"
  type        = string
  default     = "simplewebapp"
}

variable "app_name" {
  description = "Project name"
  type        = string
  default     = "simplewebapp"
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

# ECS and ECR Variables
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "simplewebapplication-nj"
}

variable "container_image_tag" {
  description = "Tag of the container image"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory for the ECS task in MB"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 2
}

variable "autoscaling_target_cpu" {
  description = "Target CPU utilization for auto-scaling"
  type        = number
  default     = 50
}

variable "autoscaling_cooldown" {
  description = "Cooldown period for auto-scaling in seconds"
  type        = number
  default     = 300
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}
