resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = merge(
    { "Name" = var.vpc_name },
    var.tags,
    var.vpc_tags,
  )
}
