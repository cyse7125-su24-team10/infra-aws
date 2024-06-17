module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "csye7125"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true 
  create_cloudwatch_log_group = false

   create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks_secrets.arn
    resources        = ["secrets"]
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  enable_irsa = true
  authentication_mode = "API_AND_CONFIG_MAP"


  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id                   = aws_vpc.eks_vpc.id
  subnet_ids               = [aws_subnet.eks_public_subnet1.id,aws_subnet.eks_public_subnet2.id, aws_subnet.eks_public_subnet3.id] #public subnets for now 
  control_plane_subnet_ids = [aws_subnet.eks_private_subnet1.id, aws_subnet.eks_private_subnet2.id, aws_subnet.eks_private_subnet3.id] #private subnets 

  # EKS Managed Node Group(s)

  eks_managed_node_groups = {
    example = {
      ami_type =  "AL2_x86_64"  
      min_size     = 3
      max_size     = 6
      desired_size = 3

      instance_types = ["c3.large"]
      capacity_type  = "ON_DEMAND"

      update_config = {
        max_unavailable = 1
      }

      create_iam_role = false
      iam_role_arn    = aws_iam_role.eks_node_group.arn

      # Figure out how to add maximum unavailable nodes 
    }
  }


  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::123456789012:role/something"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}
