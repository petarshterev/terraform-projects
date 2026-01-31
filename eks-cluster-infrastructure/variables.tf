variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "awesomeeksapp.com"
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "project name"
  type        = string
  default     = "awesomeeksapp"
}

variable "password" {
  description = "password for rds"
  type        = string
  default     = ""
}

variable "username" {
  description = "username for rds"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "db name for rds"
  type        = string
  default     = ""
}

variable "allocated_storage" {
  description = "allocated storage for rds"
  type        = number
  default     = 20
}

variable "aws_state_bucket_name" {
  description = "S3 bucket name for terraform state files"
  type        = string
  default     = "terraform-state-bucket-awesomeeksapp"
}
