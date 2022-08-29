output "vpc_ip" {
  value = aws_vpc.default.id
}

output "igw_id" {
  value = aws_internet_gateway.default.id
}
