module "vpc" {
  source = "./modules/network"

  vpc_cidr_block = "10.100.0.0/16"
  vpc_name       = "vpc-demo"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}
