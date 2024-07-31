resource "aws_security_group" "eks_node_group_allow_istio_sg" {
  name_prefix = "eks_node_group_allow_istio_sg" # Set the name prefix for the security group
  vpc_id      =  aws_vpc.eks_vpc.id           # Set the VPC ID for the security group
  ingress {
    from_port   = 15017
    to_port     = 15017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eks_node_group_allow_istio_sg"
  }
}

