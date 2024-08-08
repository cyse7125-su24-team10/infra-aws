##### THIS IS TEMPORARY. MIGHT REMOVE LATER #### 

/*
# Data source to reference the Elastic IP allocation
data "aws_eip" "nat_eks_eip" {
  filter {
    name = var.nat_eks_eip_name
    values = var.nat_eks_elastic_ip
  }
}
*/

# IAM OIDC Provider
data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

data "aws_route53_zone" "primary" {
  name = var.route53_hosted_zone
}
