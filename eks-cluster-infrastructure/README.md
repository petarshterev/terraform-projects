# EKS Cluster Infrastructure

This Terraform project provisions a fully managed EKS cluster infrastructure on AWS, including networking, database, and load balancing components.

## Architecture

The infrastructure consists of the following components:

-   **VPC**: A dedicated VPC with public and private subnets across 2 Availability Zones.
-   **EKS Cluster**: A fully managed Kubernetes control plane with a Managed Node Group (2 worker nodes).
-   **RDS**: A PostgreSQL database instance located in private subnets, accessible only from the EKS cluster.
-   **ALB**: An Application Load Balancer handling ingress traffic.
-   **ACM**: SSL/TLS certificate management for `awesomeeksapp.com`.
-   **Route53**: DNS records for validation and ALB alias.

## Prerequisites

-   Terraform >= 1.0
-   AWS Credentials configured (e.g., `~/.aws/credentials` or environment variables).
-   A registered domain in Route53 (default: `awesomeeksapp.com`).
-   S3 Bucket for Terraform State (default: `terraform-state-bucket-awesomeeksapp`).
   
   **Important!** Before your first apply, you must comment out the " backend "s3" " block, so that the resources for the remote state file can be created first.
   ```bash
   terraform apply
   ```
   This may take 10-15 minutes due to certificate validation.

## inputs

The following variables are available (defined in `variables.tf`):

| Name | Description | Default |
|------|-------------|---------|
| `region` | AWS Region | `eu-central-1` |
| `domain_name` | Domain name for the application | `awesomeeksapp.com` |
| `environment` | Environment name (e.g., dev, prod) | `dev` |
| `project` | Project name | `awesomeeksapp` |
| `username` | RDS Username | `""` (Required) |
| `password` | RDS Password | `""` (Required) |
| `db_name` | RDS Database Name | `""` (Required) |
| `allocated_storage`| RDS Storage Size (GB) | `20` |

## Usage

1.  **Initialize Terraform**:
    ```bash
    # Ensure you resolve the backend issue mentioned above first
    terraform init
    terraform validate
    ```

2.  **Plan the deployment**:
    You need to provide the required variables. You can creating a `terraform.tfvars` file or pass them inline.

    ```bash
    terraform plan 
    ```

3.  **Apply the changes**:
    ```bash
    terraform apply
    ```

## Outputs

After successful application, Terraform will output:

-   `eks_cluster_endpoint`: The API endpoint for your Kubernetes cluster.
-   `eks_cluster_name`: The name of the cluster (useful for `aws eks update-kubeconfig`).
-   `rds_endpoint`: The connection string for your PostgreSQL database.
-   `alb_dns_name`: The DNS name of the Load Balancer.
