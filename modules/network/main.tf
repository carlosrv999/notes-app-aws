resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = merge(
    { "Name" = var.vpc_name },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    { "Name" = var.vpc_name },
    var.tags,
  )
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_vpc.default.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "db" {
  count = length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null

  tags = merge(
    {
      "Name" = format(
        "${var.vpc_name}-subnet-${var.database_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format(
        "${var.vpc_name}-subnet-${var.public_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_db_subnet_group" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  name        = lower(var.database_subnet_group_name)
  description = "Database subnet group for ${var.database_subnet_group_name}"
  subnet_ids  = aws_subnet.db[*].id

  tags = merge(
    {
      "Name" = lower(var.database_subnet_group_name)
    },
    var.tags,
  )
}
