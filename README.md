# infra-AWS

[![Terraform](https://img.shields.io/badge/Terraform-844FBA.svg?style=for-the-badge&logo=Terraform&logoColor=white)](https://www.terraform.io/) 
[![Amazon Web Services](https://img.shields.io/badge/Amazon%20Web%20Services-232F3E.svg?style=for-the-badge&logo=Amazon-Web-Services&logoColor=white)](https://aws.amazon.com/)
[![EKS](https://img.shields.io/badge/EKS-FF9900.svg?style=for-the-badge&logo=Amazon-EKS&logoColor=white)](https://aws.amazon.com/eks/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF.svg?style=for-the-badge&logo=GitHub-Actions&logoColor=white)](https://github.com/features/actions)

## Introduction
This repository provides Infrastructure as Code (IaC) using Terraform to provision an AWS EKS cluster with multiple node groups, IAM roles, and other AWS resources like KMS encryption and security groups. The setup includes advanced features like custom launch templates, encryption for EBS volumes, and tainting specific node groups.

## Prerequisites
Ensure the following tools are installed and configured before proceeding:
- [Terraform](https://www.terraform.io/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS credentials configured for the target environment.

## Setup Instructions

### 1. Clone the Repository
Clone the repository to your local machine:
```bash
git clone git@github.com:your-username/infra-aws.git
cd infra-aws

2. **Add terraform.tfvars file: Example below**
    ```hcl
#provider
provider_region = "us-east-1"
#vpc
eks_vpc_cidr_block = "10.0.0.0/16"
eks_vpc_tag_name = "eks-vpc"
#public subnet1
eks_public_subnet1_availability_zone = "us-east-1a"
eks_public_subnet1_cidr_block = "10.0.1.0/24"
eks_public_subnet_tag = "eks-public-subnet"
#public subnet2
eks_public_subnet2_availability_zone = "us-east-1b"
eks_public_subnet2_cidr_block = "10.0.2.0/24"
#public subnet3
eks_public_subnet3_availability_zone = "us-east-1c"
eks_public_subnet3_cidr_block = "10.0.3.0/24" 
#private subnet1
eks_private_subnet1_availability_zone = "us-east-1a"
eks_private_subnet1_cidr_block = "10.0.4.0/24" 
eks_private_subnet_tag = "eks-private-subnet"
#private subnet2
eks_private_subnet2_availability_zone = "us-east-1b"
eks_private_subnet2_cidr_block = "10.0.5.0/24" 
#private subnet3
eks_private_subnet3_availability_zone = "us-east-1c"
eks_private_subnet3_cidr_block = "10.0.6.0/24"
#Route Table
route_table_cidr_block = "0.0.0.0/0"
#EKS Module
eks_cluster_name = "csye7125"
eks_cluster_version = "1.29"
eks_cluster_authentication_mode = "API_AND_CONFIG_MAP"
#EKS managed node group
ami_type = "AL2_x86_64"
min_size = 3
max_size = 7
desired_size = 4
instance_types = [ "c3.large" ]
capacity_type = "ON_DEMAND"
max_unavailable = 1
#Block device mappings 
device_name = "/dev/xvda"
ebs_volume_size = 20
ebs_volume_type = "gp2"
#tags
environment_tag = "dev"
#Cluster encryption config resources
cluster_encryption_config_resources = ["secrets"]
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
#KMS KEYS
eks_secrets_key_description = "KMS key for EKS secrets encryption"
deletion_window_in_days = 7
ebs_key_description = "KMS key for EBS encryption"
ebs_key_usage = "ENCRYPT_DECRYPT"
customer_master_key_spec = "SYMMETRIC_DEFAULT"
github_token = "your_github_api_key"
autoscaler_version = "1.0.0"
#Ingress values 
istio_ingress_values = <<-EOT
service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    external-dns.alpha.kubernetes.io/hostname: "grafana.prod.skynetx.me,cve.prod.skynetx.me"
  ports:
    - port: 80
      targetPort: 8080
      name: http2
    - port: 443
      targetPort: 8443
      name: https
    - port: 15021
      targetPort: 15021
      name: status-port
  type: LoadBalancer
EOT
#EKS Blueprint addon
cert_manager_route53_hosted_zone_arns = ["arn:aws:route53:::hostedzone/your_hosted_zone_id"]
route53_hosted_zone =  "prod.skynetx.me"

3. **Setup aws profile on cli**
    ```bash
    export AWS_PROFILE=dev
    ```

4. **Initialize Terraform:**
    ```bash
    terraform init
    ```

5. **Terraform Configuration:**
   Review the `terraform.tfvars`. Modify variables in `terraform.tfvars` as needed for your environment.

6. **Plan Infrastructure Changes:**
    ```bash
    terraform plan
    ```

6. **Apply Infrastructure Changes:**
    ```bash
    terraform apply
    ```

7. **Verify the Infrastructure:**
   After Terraform applies the changes successfully, verify the infrastructure on GCP.

## Cleaning Up
Instructions for tearing down the infrastructure

1. **Destroy Infrastructure:**
    ```bash
    terraform destroy
    ```

2. **Confirm Destruction:**
   Terraform will prompt you to confirm destruction. Enter `yes` to proceed with tearing down the infrastructure.
