module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true 
  create_cloudwatch_log_group = false
  depends_on = [ aws_iam_role.eks_cluster, aws_iam_role.eks_node_group ]

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks_secrets.arn
    resources        = var.cluster_encryption_config_resources
  }

  enable_irsa = true
  authentication_mode = var.eks_cluster_authentication_mode


  cluster_enabled_log_types = var.cluster_enabled_log_types

  vpc_id                   = aws_vpc.eks_vpc.id
  subnet_ids               = [aws_subnet.eks_public_subnet1.id,aws_subnet.eks_public_subnet2.id, aws_subnet.eks_public_subnet3.id] #public subnets for now 
  control_plane_subnet_ids = [aws_subnet.eks_private_subnet1.id, aws_subnet.eks_private_subnet2.id, aws_subnet.eks_private_subnet3.id] #private subnets 

  #comment if issue with the role
  create_iam_role = false
  iam_role_arn = aws_iam_role.eks_cluster.arn

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({"enableNetworkPolicy": "true"})
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)

  eks_managed_node_groups = {
    vk = {
      ami_type =  var.ami_type 
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
      # launch_template_id = "lt-0"
       use_custom_launch_template = true
       create_launch_template = true

      update_config = {
        max_unavailable = var.max_unavailable
      }
      block_device_mappings = [
        {
          device_name = var.device_name
          ebs = {
            encrypted   = true
            volume_size = var.ebs_volume_size
            kms_key_id  = aws_kms_key.ebs.arn
            volume_type = var.ebs_volume_type
          }
        }
      ]
      create_iam_role = false
      iam_role_arn    = aws_iam_role.eks_node_group.arn

      vpc_security_group_ids = [aws_security_group.eks_node_group_allow_istio_sg.id]
    }

        # New node group for c3.2xlarge instances
    ollama = {
      ami_type      = "AL2_x86_64"  # or your preferred AMI type
      min_size      = 1
      max_size      = 1
      desired_size  = 1

      instance_types = ["r6id.2xlarge"]
      capacity_type  = "ON_DEMAND"  # or "SPOT" if you prefer

      use_custom_launch_template = true
      create_launch_template     = true

      update_config = {
        max_unavailable = 1
      }

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            encrypted   = true
            volume_size = 100  # adjust as needed
            kms_key_id  = aws_kms_key.ebs.arn
            volume_type = "gp3"
          }
        }
      ]

      create_iam_role = false
      iam_role_arn    = aws_iam_role.eks_node_group.arn

      vpc_security_group_ids = [aws_security_group.eks_node_group_allow_istio_sg.id]

      # Apply taint to the node group
      taints = [
        {
          key    = "dedicated"
          value  = "ollama"
          effect = "NO_SCHEDULE"
        }
      ]

      labels = {
        instance-type = "r6id.2xlarge"
      }
    }
  }


  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    root = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = var.environment_tag
    Terraform   = "true"
  }
}

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = module.eks.cluster_oidc_issuer_url
# }
