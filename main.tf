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

module "database" {
  source = "./modules/database"

  db_subnet_group_name = module.vpc.aws_db_subnet_group
  db_password          = var.db_password
  db_instance_name     = "postgres-1"

  security_group_ids = [
    aws_security_group.rds.id
  ]
}

module "iam" {
  source = "./modules/iam"
}

module "container" {
  source = "./modules/container"

  db_endpoint             = module.database.endpoint
  db_password             = var.db_password
  container_image         = var.container_image
  subnets                 = module.vpc.public_subnets_ids
  task_execution_role_arn = module.iam.task_execution_role_arn
  security_group_ids      = [aws_security_group.ecs.id]
}

resource "aws_security_group" "rds" {
  name        = "rds-secgroup"
  description = "This is the security group for the RDS cluster"
  vpc_id      = module.vpc.vpc_ip

  tags = {
    Name = "rds-secgroup"
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-task-notes-web-secgroup"
  description = "This is the security group for the Notes webapp ECS service"
  vpc_id      = module.vpc.vpc_ip

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

resource "null_resource" "init_db" {
  provisioner "local-exec" {
    command = "./restore-db.sh ${var.db_password} ${module.database.endpoint}"
  }
}
