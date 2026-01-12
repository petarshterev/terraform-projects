# AWS Simple Web Application Infrastructure

This project provides Terraform code to deploy a secure, high-availability web application infrastructure on AWS. It sets up a VPC with public and private subnets, an Application Load Balancer (ALB) with HTTPS termination, EC2 instances running a simple web app, and a PostgreSQL RDS database. The infrastructure includes remote state management with S3 and DynamoDB for locking.

## Architecture Overview

The infrastructure consists of the following components:

- :white_check_mark: **VPC**: Isolated network with public and private subnets across 2 availability zones.
- :white_check_mark: **ALB**: Internet-facing load balancer with HTTP->HTTPS listener using an AWS ACM certificate.
- :white_check_mark: **EC2 Instances**: Private instances running a basic Apache web server (demo app).
- :white_check_mark: **RDS PostgreSQL**: Private database accessible only from EC2 instances.
- :white_check_mark: **Route53**: DNS management and ACM certificate validation.
- :white_check_mark: **Security Groups**: Restrictive rules allowing only necessary traffic.
- :white_check_mark: **Remote State**: S3 bucket for state storage with versioning and encryption; DynamoDB for state locking.

### High-Level Diagram
```
Internet
    |
    v
ALB (HTTPS) --> EC2 Instances (Private) --> RDS PostgreSQL (Private)
    ^
    |
Route53 (DNS)
```

## Prerequisites

- **AWS Account**: With permissions to create VPC, EC2, RDS, ALB, Route53, S3, DynamoDB, and ACM resources.
- **Terraform**: Version 1.0+ (tested with 1.14+).
- **AWS CLI**: Configured with your credentials (`aws configure`).
- **Domain**: A registered domain pointed to AWS Route53 nameservers (for ACM certificate).
- **Git**: For cloning this repository (if applicable).

## Project Structure

```
aws-simple-web-application/
├── main.tf          # Main Terraform configuration
└── variables.tf     # Variable definitions
└── output.tf        # Terraform outputs
README.md            # This file

modules/aws_instance # Module for EC2 instance

```

## Setup Instructions

1. **Clone or Download the Project**:
   ```bash
   git clone <repository-url>
   cd aws-simple-web-application
   ```

2. **Configure AWS Credentials**:
   Ensure your AWS CLI is configured or set environment variables:
   ```bash
   export AWS_ACCESS_KEY_ID=your-access-key
   export AWS_SECRET_ACCESS_KEY=your-secret-key
   export AWS_DEFAULT_REGION=eu-central-1
   ```

3. **Set Variables**:
   Create a `terraform.tfvars` file in the `aws-simple-web-application/` folder:
   ```hcl
   db_username = "your-db-username"
   db_password = "your-db-password"
   # Other variables can be overridden if needed
   ```
   Alternatively you can pass these secrets from a secrets store like Hashicorp Vault or AWS KMS :wink: 

4. **Validate the syntax/configuration and Initialize Terraform**:
   ```bash
   terraform validate
   terraform init
   ```

## Deployment Steps

1. **Review the Plan**:
   ```bash
   terraform plan
   ```
   This shows what will be created. Review for any issues.

2. **Apply the Configuration**:

   **Important!** Before your first apply, you must comment out the " backend "s3" " block, so that the resources for the remote state file can be created first.
   ```bash
   terraform apply
   ```
   This may take 10-15 minutes due to certificate validation.

3. **Monitor Outputs**:
   After successful apply, note the outputs:
   - `alb_dns_name`: The ALB's DNS name (point your domain's A record here).
   - `rds_endpoint`: The database endpoint for app connections.
   - `route53_zone_id`: The hosted zone ID.

## Remote State Management

The configuration includes S3 and DynamoDB for remote state:

- **Initial Setup**: Comment out the `terraform { backend "s3" { ... } }` block in `main.tf`, run `terraform apply` to create the bucket/table, then uncomment and run `terraform init` to migrate state.
- **Locking**: Prevents concurrent Terraform runs.
- **Versioning**: Allows state recovery from S3.

## Security Considerations

- **HTTPS Only**: The traffic to the ALB can be over both HTTP and HTTPS, but the ALB upgrades any HTTP connections to HTTPS.
- **Private Resources**: EC2 and RDS are in private subnets.
- **Security Groups**: Minimal ingress rules (ALB to EC2 on 80, EC2 to RDS on 5432, SSH allowed only from VPC). For troubleshooting purposes you have to either use the EC2 console or manually create an additional EC2 jumphost.
- **Encryption**: S3 state bucket uses AES256 encryption.
- **No Public SSH**: SSH access only from within the VPC.

## Customization

- **Instance Count**: Adjust `aws_instances_number` in `variables.tf`.
- **Region**: Change `region` variable (ensure AMI and AZs are compatible).
- **App Deployment**: Replace the user data script in EC2 resource with your app code.
- **Database**: Modify RDS settings for production (e.g., larger instance, backups, multi-AZ replicas, or read replicas).
