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
