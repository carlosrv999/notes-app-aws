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
