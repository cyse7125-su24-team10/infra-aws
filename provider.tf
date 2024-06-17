terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.provider_region
}

