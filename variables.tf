#provider
variable provider_region {}
#eks vpc 
variable eks_vpc_cidr_block {}
variable eks_vpc_tag_name {}
#eks public subnet1
variable eks_public_subnet1_cidr_block {}
variable eks_public_subnet1_availability_zone {}
variable eks_public_subnet_tag {}
#eks public subnet2
variable eks_public_subnet2_cidr_block {}
variable eks_public_subnet2_availability_zone {}
#eks public subnet3
variable eks_public_subnet3_cidr_block {}
variable eks_public_subnet3_availability_zone {}
#eks private subnet1
variable eks_private_subnet1_cidr_block {}
variable eks_private_subnet1_availability_zone {}
variable eks_private_subnet_tag {}
#eks private subnet2
variable eks_private_subnet2_cidr_block {}
variable eks_private_subnet2_availability_zone {}
#eks private subnet3
variable eks_private_subnet3_cidr_block {}
variable eks_private_subnet3_availability_zone {}
#Route Table
variable route_table_cidr_block {}
#eip allocation 
#variable nat_eks_eip_name {}
#variable nat_eks_elastic_ip {
#    type = list(string)
#}
#EKS module
variable eks_cluster_name {}
variable eks_cluster_version {}
variable eks_cluster_authentication_mode {}

#EKS managed node group
variable ami_type {}
variable min_size {}
variable max_size {}
variable desired_size {}
variable instance_types {
    type = list(string)
}
variable capacity_type {}
variable max_unavailable {}
#block device mappings
variable device_name {}
variable ebs_volume_size {}
variable ebs_volume_type {}
#tags
variable environment_tag {}
#Cluster encryption config resources
variable cluster_encryption_config_resources {
    type = list(string)
}
variable cluster_enabled_log_types {
    type = list(string)
}
#KMS KEYS
variable eks_secrets_key_description {}
variable deletion_window_in_days {}
variable ebs_key_description {}
variable ebs_key_usage {}
variable customer_master_key_spec {}
variable "github_token" {
  description = "GitHub token"
}
variable "autoscaler_version" {
  
}
  #EKS Blueprint addon 
variable "cert_manager_route53_hosted_zone_arns" {
  description = "ARNs for the Route53 hosted zones used by cert manager"
  type        = list(string)
}

variable "istio_ingress_values" {
  description = "Values for the Istio Ingress Helm release"
  type        = string
}

variable "route53_hosted_zone" {
    description = "Route53 hosted zone"
    type        = string
}

