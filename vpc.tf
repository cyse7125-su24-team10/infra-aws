#Creating Jenkins VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block       = var.eks_vpc_cidr_block
  tags = {
    Name = var.eks_vpc_tag_name
  }
}

#Public subnet1 for the eks vpc
resource "aws_subnet" "eks_public_subnet1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block         = var.eks_public_subnet1_cidr_block
  availability_zone = var.eks_public_subnet1_availability_zone
  tags = {
    Name = var.eks_public_subnet_tag
  }
}

#Public subnet2 for the eks vpc
resource "aws_subnet" "eks_public_subnet2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block         = var.eks_public_subnet2_cidr_block
  availability_zone = var.eks_public_subnet2_availability_zone
  tags = {
    Name = var.eks_public_subnet_tag
  }
}

#Public subnet3 for the eks vpc
resource "aws_subnet" "eks_public_subnet3" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block         = var.eks_public_subnet3_cidr_block
  availability_zone = var.eks_public_subnet3_availability_zone
  tags = {
    Name = var.eks_public_subnet_tag
  }
}

#Private subnet1 for the eks vpc
resource "aws_subnet" "eks_private_subnet1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block         = var.eks_private_subnet1_cidr_block
  availability_zone = var.eks_private_subnet1_availability_zone
  tags = {
    Name = var.eks_private_subnet_tag
  }
}

#Private subnet2 for the eks vpc
resource "aws_subnet" "eks_private_subnet2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block         = var.eks_private_subnet2_cidr_block
  availability_zone = var.eks_private_subnet2_availability_zone
  tags = {
    Name = var.eks_private_subnet_tag
  }
}

#Private subnet3 for the eks vpc
resource "aws_subnet" "eks_private_subnet3" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block         = var.eks_private_subnet3_cidr_block
  availability_zone = var.eks_private_subnet3_availability_zone
  tags = {
    Name = var.eks_private_subnet_tag
  }
}

# Internet gateway for the vpc
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

#Route table 
resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.eks_igw.id
  }
}

#jenkins public subnet1 and route table association
resource "aws_route_table_association" "jenkins_public_subnet1_association" {
  subnet_id         = aws_subnet.eks_public_subnet1.id
  route_table_id     = aws_route_table.eks_public_route_table.id
}

#jenkins public subnet2 and route table association
resource "aws_route_table_association" "jenkins_public_subnet2_association" {
  subnet_id         = aws_subnet.eks_public_subnet2.id
  route_table_id     = aws_route_table.eks_public_route_table.id
}

#jenkins public subnet3 and route table association
resource "aws_route_table_association" "jenkins_public_subnet3_association" {
  subnet_id         = aws_subnet.eks_public_subnet3.id
  route_table_id     = aws_route_table.eks_public_route_table.id
}


/*
####### TEMPORARY #########
# Create a NAT Gateway with the EIP
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.eks_public_subnet1.id
}


# Create a new route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.eks_private_subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet2_association" {
  subnet_id      = aws_subnet.eks_private_subnet2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet3_association" {
  subnet_id      = aws_subnet.eks_private_subnet3.id
  route_table_id = aws_route_table.private.id
}
####### TEMPORARY #########
*/