variable "region" {
  type    = string
  default = "us-east-2"
}

variable "db_password" {
  type      = string
  sensitive = true
}
