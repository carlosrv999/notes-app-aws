resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  copy_tags_to_snapshot  = true
  db_subnet_group_name   = var.db_subnet_group_name
  engine                 = "postgres"
  engine_version         = "14.4"
  identifier             = var.db_instance_name
  instance_class         = var.instance_class
  multi_az               = false
  network_type           = "IPV4"
  port                   = 5432
  publicly_accessible    = true
  skip_final_snapshot    = true
  storage_encrypted      = true
  storage_type           = "gp2"
  username               = "postgres"
  password               = var.db_password
  vpc_security_group_ids = var.security_group_ids[*]
}
