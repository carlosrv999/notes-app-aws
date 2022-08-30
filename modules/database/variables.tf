variable "db_subnet_group_name" {
  type        = string
  description = "Name of DB subnet group"
}

variable "instance_class" {
  type        = string
  description = "Flavor of DB instance"
  default     = "db.m6i.large"
}

variable "db_instance_name" {
  type    = string
  default = "database-1"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "security_group_ids" {
  type = list(string)
}

variable "db_password" {
  type      = string
  sensitive = true
}
