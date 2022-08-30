variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_endpoint" {
  type = string
}

variable "container_image" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
