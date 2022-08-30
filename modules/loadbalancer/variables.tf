variable "subnet_ids" {
  type = list(string)
}

variable "security_groups_ids" {
  type = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type = string
}
