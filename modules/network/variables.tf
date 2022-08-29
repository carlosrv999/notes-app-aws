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
