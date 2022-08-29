variable "vpc_name" {
  type        = string
  description = "Name of VPC"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "A map of tags to add to VPC resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr_block" {
  type        = string
  description = "Name of VPC"
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
  default     = []
}

variable "database_subnet_suffix" {
  description = "A suffix for database subnets"
  type        = string
  default     = "db"
}

variable "public_subnet_suffix" {
  description = "A suffix for public subnets"
  type        = string
  default     = "public"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}
