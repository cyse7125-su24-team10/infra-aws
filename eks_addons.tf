module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" 
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  enable_external_dns                    = true
  enable_cert_manager                    = true
  cert_manager_route53_hosted_zone_arns  = var.cert_manager_route53_hosted_zone_arns

  tags = {
    Environment = "cert-manager"
  }
}