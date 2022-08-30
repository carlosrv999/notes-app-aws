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

output "aws_db_subnet_group" {
  value = try(aws_db_subnet_group.database[0].name, "")
}

output "sg_rds_id" {
  value = aws_security_group.rds.id
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "sg_ecs_id" {
  value = aws_security_group.ecs.id
}
