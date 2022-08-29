output "vpc_ip" {
  value = aws_vpc.default.id
}

output "igw_id" {
  value = aws_internet_gateway.default.id
}

output "public_subnets_ids" {
  value = aws_subnet.public[*].id
}

output "db_subnets_ids" {
  value = aws_subnet.db[*].id
}
