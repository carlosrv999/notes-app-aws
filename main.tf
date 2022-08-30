module "vpc" {
  source = "./modules/network"

  vpc_cidr_block   = "10.100.0.0/16"
  vpc_name         = "vpc-demo"
  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  database_subnets = ["10.100.101.0/26", "10.100.101.64/26", "10.100.101.128/26"]
  public_subnets   = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

resource "aws_security_group" "rds" {
  name        = "rds-secgroup"
  description = "This is the security group for the RDS cluster"
  vpc_id      = module.vpc.vpc_ip

  tags = {
    Name = "rds-secgroup"
  }
}

resource "aws_security_group_rule" "rds-secgroup-allow-from-home" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["38.25.18.114/32"]
  security_group_id = aws_security_group.rds.id
}

module "database" {
  source = "./modules/database"

  db_subnet_group_name = module.vpc.aws_db_subnet_group
  db_password          = var.db_password
  db_instance_name     = "postgres-1"

  security_group_ids = [
    aws_security_group.rds.id
  ]
}
