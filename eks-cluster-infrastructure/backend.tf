terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  /*backend "s3" {
    bucket       = var.aws_state_bucket_name
    key          = "workspace/terraform.tfstate"
    region       = var.region
    encrypt      = true
    use_lockfile = true
  }*/
}
