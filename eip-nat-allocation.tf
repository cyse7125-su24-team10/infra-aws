/*
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_nat_gateway.nat.id
  allocation_id = data.aws_eip.nat_eks_eip.id
}
*/