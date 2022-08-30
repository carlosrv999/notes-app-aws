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

resource "aws_security_group" "rds" {
  name        = "rds-secgroup"
  description = "This is the security group for the RDS cluster"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "rds-secgroup"
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-secgroup"
  description = "This is the security group for the ALB"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "alb-secgroup"
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-task-notes-web-secgroup"
  description = "This is the security group for the Notes webapp ECS service"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "ecs-task-notes-web-secgroup"
  }
}

resource "aws_security_group_rule" "allow_home" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["38.25.18.114/32"]
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "allow_tcp_anywhere" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "allow_alb_http_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_outgoing" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "container_outgoing" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}
