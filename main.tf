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
    module.vpc.sg_rds_id
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "iam" {
  source = "./modules/iam"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "container" {
  source = "./modules/container"

  db_endpoint             = module.database.endpoint
  db_password             = var.db_password
  container_image         = var.container_image
  subnets                 = module.vpc.public_subnets_ids
  task_execution_role_arn = module.iam.task_execution_role_arn
  security_group_ids      = [module.vpc.sg_ecs_id]
  target_group_arn        = module.loadbalancer.target_group_arn
  replicas                = 5

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  security_groups_ids = [module.vpc.sg_alb_id]
  subnet_ids          = module.vpc.public_subnets_ids[*]
  vpc_id              = module.vpc.vpc_ip

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "null_resource" "init_db" {
  provisioner "local-exec" {
    command = "./restore-db.sh ${var.db_password} ${module.database.endpoint}"
  }
}
